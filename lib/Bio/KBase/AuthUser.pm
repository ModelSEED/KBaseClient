package Bio::KBase::AuthUser;

use strict;
use warnings;
use JSON;
use Digest::SHA1 qw(sha1_base64);
use Bio::KBase::Auth;
use Bio::KBase::AuthToken;
use LWP::UserAgent;
use URI::URL;
use MIME::Base64;

# We use Object::Tiny::RW to generate getters/setters for the attributes
# and save ourselves some tedium
use Object::Tiny::RW qw {
    token
    error_message
    enabled
    groups
    oauth_creds
    name
    email
    verified
};

# Pull the INI files based configs in
our %Conf = %Bio::KBase::Auth::AuthConf;
our $VERSION = $Bio::KBase::Auth::VERSION;

# Hash for caching the user profiles
our $ProfileCache;
our $ProfileCacheSize = exists($Conf{'authentication.profile_cache_size'}) ?
                              $Conf{'authentication.profile_cache_size'} : 50;

# Lifetime in seconds for profile objects to stay in the cache, default to 10 minutes
our $ProfileCacheTTL = exists($Conf{'authentication.profile_cache_ttl'}) ?
                              $Conf{'authentication.profile_cache_ttl'} : 600;

# Pickup the cache hashing salt from configs
our $CacheKeySalt = exists($Conf{'authentication.cache_salt'}) ?
                           $Conf{'Authentication.cache_salt'} : "NaCl";

# If enabled, create some shared memory hashes for our cache.
# Make them only readable/writeable by ourselves
if ($Conf{'authentication.shm_cache'}) {
}

$ProfileCache = "";

# Mapping of internal user attribute names to
# top level Globus Online profile attributes.
# Attributes not in this list go into the
# nested "custom_fields" of globus online
our %top_attrs = ( "user_id" => "username",
		   "verified" => "email_validated",
		   "opt_in" => "opt_in",
		   "name" => "fullname",
		   "email" => "email",
		   "system_admin" => "system_admin");


sub new() {
    my $class = shift;

    # Don't bother with calling the Object::Tiny::RW constructor,
    # since it doesn't do anything except return a blessed empty hash
    my $self = $class->SUPER::new(
        'oauth_creds' => {},
        @_
    );

    # If we're passed in a token parameter, push it into the oauth_creds->oauth_token
    if ( $self->{'token'}) {
	$self->{'oauth_creds'}->{'auth_token'} = $self->{'token'};
	undef(  $self->{'token'});
    }
    if (  $self->{'oauth_creds'}->{'auth_token'}) {
	$self->get();
    }
    return($self);
}

# Caches are implemented as a largish string structures in CSV
# format with the following entries per line:
# last_seen,key:lookup_key,value:cached_value
# This is to simplify storage in memory for a shared memory
# segment, and also to allow the use of fast regex functions
# to manage the cache

# fetch something from the cache
# cache_get( cache, key)
# cache is a reference to the string used to store the cache
# key is the value of the object to compare to see if there is
#  a cache hit
# If the last seen time is more than $ProfileCacheTTL, then
# treat it as expired and remove it from the cache
# returns true or false for if the key is found
sub cache_get {
    my($cache, $key) = @_;

    # Convert the key to a salted sha1 hash
    my $keyhash = sha1_base64( $key.$CacheKeySalt);
    my $key2 = quotemeta( $keyhash);
    if ($$cache =~ m/^(\d+),key:($key2),value:(.+)$/m ) {
	my $last = $1;
	$key = $2;
	my $value = $3;
	if ( $last + $ProfileCacheTTL >= time()) {
	    # Update last seen time
	    my $now = time();
	    $$cache =~ s/^$last,key:$key2/$now,key:$key/m;
	    return($value);
	} else {
	    # Expire it the lazy way by setting the timestamp
	    # to 0 so that this entry would get pushed out of
	    # the cache as new entries come in
	    my $now = time();
	    $$cache =~ s/^$last,key:$key2,value:.*/0,key:_expired_:value:_expired_/m;
	    return(undef);
	}
    } else {
	return( undef );
    }
}

# cache_set( cache, maxrows, key, value)
# cache is a reference to the string used for the cache
# maxrows is the maximum number of rows that can be in the cache
# key is the value of the object to use for future comparison
# value is the value to be stored there - it is expected to be a scalar
# The cache is ordered by last seen time and anything more than the
# maxrows is dropped
# returns the value stored if successful
sub cache_set {
    my($cache, $maxrows, $key, $value) = @_;
    my($keyhash) = sha1_base64( $key.$CacheKeySalt);
    my(@cache) = split /\n/, $$cache;
    push @cache, sprintf("%d,key:%s,value:%s",time(),$keyhash,$value);
    my(@new) = sort {$b cmp $a} @cache;
    if ($#new >= $maxrows) {
	@new = @new[0..($maxrows-1)];
    }
    $$cache = join "\n", @new;
    return $value;
}

sub user_id {
    my $self = shift;
    my $user_id = shift;

    # If there is a user_id value set already, do not accept a new
    # value, just return the old value

    if ($user_id && !(exists $self->{user_id})) {
	$self->{'user_id'} = $user_id;
    }
    $self->error_message(undef);
    return( $self->{'user_id'});
}

# This function updates the current user record. We must be
# logged in, and the parameters are a hash of the name/values
# that are to be updated. Returns a reference to itself
# if successful, with the attributes reloaded from the
# profile server. Returns undef if there is an error.
# Attributes that aren't part of the @top_attrs list defined
# at the top of this module are pushed into the custom_fields
# hash.
# A special hash key called "__subpath__" can be defined to
# have it added to the URL path, for updating a subpath, like
# credentials/ssh. In general, any hash key beginning with
# an _ will be dropped from the updates
sub update {
    my $self = shift;
    my %p = @_;

    eval {
	$self->error_message(undef);
	my $json;
	my $token = $self->oauth_creds->{'auth_token'};
	my $path = $Bio::KBase::Auth::ProfilePath;
	unless ($token) {
	    die "Not logged in.";
	}
	my ($user_id) = $token =~ /un=(\w+)/;
	unless (keys( %p)) {
	    die "No values for update";
	}
	$path .= "/".$self->{'user_id'};
	if (defined( $p{'__subpath__'})) {
	    $path .= "/".$p{'__subpath__'};
	}
	# strip out any hash keys that begin with "_"
	my %attrs = map { $_, $p{$_}} grep { ! /^_/ } (keys %p);
	# construct top level hash for appropriate attrs
	my %top;
	foreach my $x (keys %top_attrs) {
	    if (exists($attrs{ $x})) {
		$top{$top_attrs{$x}} = $attrs{$x};
		delete( $attrs{$x});
	    }
	}
	# any leftovers go into custom_fields
	if (keys %attrs) {
	    $top{'custom_fields'} = \%attrs;
	}
	$json = to_json( \%top);

	# go_request will die() unless it goes through
	my $res = $self->go_request('token' => $token, 'method' => 'PUT',
				    'body' => $json, 'path' => $path);
    };
    if ($@) {
	my $err = "Error while updating user: $@";
	$self->error_message($err);
	return(undef);
    }
    return( $self->get( nocache => 1));
}

# Tries to fetch a user's profile from the Globus Online auth
# service using the authentication token passed in
# Sets all the appropriate attributes based on the return values
# returns a reference to self if successsful, returns undef
# if not
sub get {
    my $self = shift @_;
    my %p = @_;

    # my $token = shift @_;

    eval {
	$self->error_message(undef);
	my $path = $Bio::KBase::Auth::ProfilePath;
	my %headers;
	# if we aren't passed a token, try to pull it from the
	# the existing record
	unless ($p{token}) {
	    $p{token} = $self->{'oauth_creds'}->{'auth_token'};
	}
	unless( $p{token} ) {
	    die "Authentication token required";
	}
	my ($user_id) = $p{token} =~ /un=(\w+)/;
	unless ($user_id) {
	    die "Failed to parse username from un= clause in token. Is the token legit?";
	}
	# Query the roles service for role/group membership first to make
	# sure they are legit before filling in any fields from profile
	my %groups = $self->roles_request( user_id => $user_id, token=> $p{token});
	my @groups = keys( %groups);
	$self->{'groups'} = \@groups;

	my $nuser; # nexus user profile
	# Check to see if the token matches a profile in the cache, if it does and the token
	# validates, then return the profile, otherwise fetch it
	if ( !$p{nocache} &&
	     (my $profile = cache_get( \$ProfileCache, $p{token})) &&
	     Bio::KBase::AuthToken->new( token => $p{token})->validate()) {
	    $nuser = from_json( decode_base64( $profile));
	} else {

	    $path = sprintf('%s/%s?fields=groups,username,email_validated,fullname,email,custom_fields',$path,$user_id);
	    
	    # go_request will throw an error if it chokes and exit this eval block
	    $nuser = $self->go_request( 'path' => $path, 'token' => $p{token});
	    unless ($nuser->{'username'}) {
		die "No user found by name of $user_id";
	    }
	    cache_set( \$ProfileCache, $ProfileCacheSize, $p{token}, encode_base64( to_json( $nuser), '')) if
		! $p{nocache};
	}
	$self->{'oauth_creds'}->{'auth_token'} = $p{token};
	foreach my $x (keys %top_attrs) {
	    $self->{$x} = $nuser->{$top_attrs{$x}};
	}
	foreach my $x (keys %{$nuser->{'custom_fields'}}) {
	    $self->{$x} = $nuser->{'custom_fields'}->{$x};
	}
    };
    if ($@) {
	$self->error_message("Failed to get profile: $@");
	return( undef);
    } else {
	$self->error_message(undef);
	return( $self);
    }
    
}

# function that handles Globus Online requests
# takes the following params in hash
# path => path/query part of the URL, doesn't include protocol/host
# token => token string to be used, if not provided will
#         look for oauth_creds->oauth_token. Value will go
#         into X-GLOBUS-GOAUTHTOKEN header
# method => (GET|PUT|POST|DELETE) defaults to GET
# body => string for http content
#         Content-Type will be set to application/json
#         automatically
# headers => hashref for any additional headers to be put into
#         the request. X-GLOBUS-GOAUTHTOKEN automatically set
#         by token param
#
# Returns a hashref to the json data that was returned
# throw an exception if there is an error, make sure you
# trap this with an eval{}!
sub go_request {
    my $self = shift @_;
    my %p = @_;

    my $json;
    eval {
	$self->error_message(undef);
	my $baseurl = $Bio::KBase::Auth::AuthSvcHost;
	my %headers;
	unless ($p{'token'}) {
	        $p{'token'} = $self->oauth_creds->{'auth_token'};
	}
	unless ($p{'token'}) {
	    die "No authentication token";
	}
	unless ($p{'path'}) {
	    die "No path specified";
	}
	$headers{'Authorization'} = 'Globus-Goauthtoken ' . $p{'token'};
	$headers{'Content-Type'} = 'application/json';
	if (defined($p{'headers'})) {
	    %headers = (%headers, %{$p{'headers'}});
	}
	my $headers = HTTP::Headers->new( %headers);
    
	my $client = LWP::UserAgent->new(default_headers => $headers);
	$client->timeout(5);
	$client->ssl_opts(verify_hostname => 0);
	my $method = $p{'method'} ? $p{'method'} : "GET";
	my $url = sprintf('%s%s', $baseurl,$p{'path'});
	my $req = HTTP::Request->new($method, $url);
	if ($p{'body'}) {
	    $req->content( $p{'body'});
	}
	my $response = $client->request( $req);
	unless ($response->is_success) {
	    die $response->status_line;
	}
	$json = decode_json( $response->content());
	$json = $self->_SquashJSONBool( $json);
    };
    if ($@) {
	die "Failed to query Globus Online: $@";
    } else {
	return( $json);
    }

}

#
# Submit a request to the Roles service defined in
# Bio::KBase::Auth::RolesSvcURL to fetch the roles that
# a user is a member of. Returns a hash keyed on
# role_id with values as simply 1
#
sub roles_request {
    my $self = shift @_;
    my %p = @_;

    my %groups;
    my $json;
    my $user_id;
    eval {
	$self->error_message(undef);
	my $baseurl = $Bio::KBase::Auth::RoleSvcURL;
	my %headers;
	unless ($p{'token'}) {
	        $p{'token'} = $self->oauth_creds->{'auth_token'};
	}
	unless ($p{'token'}) {
	    die "No authentication token";
	}
	unless ($p{'user_id'}) {
	    $p{'user_id'} = $self->user_id;
	}
	unless ( $p{'user_id'}) {
	    die "No user specified";
	}

	$headers{'Authorization'} = 'OAuth ' . $p{'token'};
	$headers{'Content-Type'} = 'application/json';
	if (defined($p{'headers'})) {
	    %headers = (%headers, %{$p{'headers'}});
	}
	my $headers = HTTP::Headers->new( %headers);
    
	my $client = LWP::UserAgent->new(default_headers => $headers);
	$client->timeout(5);
	$client->ssl_opts(verify_hostname => 0);
	# URL params to return only the role_id's for this current user
	my $url = url( $baseurl);
	$url->query_form( filter => '{ "members" : "'.$p{'user_id'}.'"}',
			  fields => '{ "role_id" : "1" }');

	my $response = $client->get( $url->as_string);
	unless ($response->is_success) {
	    if (($response->code == 401) || ($response->code == 403)) {
		die $p{'user_id'}." is not a recognized KBase User";
	    } else {
		die $response->status_line;
	    }
	}
	$json = decode_json( $response->content());
	%groups = map { $_->{'role_id'} => 1 } @$json;
    };
    if ($@) {
	die $@;
    } else {
	return( %groups);
    }

}

sub _SquashJSONBool {
    # Walk an object ref returned by from_json() and squash references
    # to JSON::XS::Boolean into a simple 0 or 1
    my $self = shift;
    my $json_ref = shift;
    my $type;

    foreach (keys %$json_ref) {
	$type = ref $json_ref->{$_};
	next unless ($type);
	if ( 'HASH' eq $type) {
	    _SquashJSONBool( $self, $json_ref->{$_});
	} elsif ( 'JSON::XS::Boolean' eq $type) {
	    $json_ref->{$_} = ( $json_ref->{$_} ? 1 : 0 );
	}
    }
    return $json_ref;
}


1;

__END__

=pod

=head1 Bio::KBase::AuthUser

User object for KBase authentication. Stores user profile and authentication information, including oauth credentials.

This is a container for user attributes - creating, destroying them in the user database is handled by the Bio::KBase::AuthDirectory class.

=head2 Examples

   my $user = Bio::KBase::AuthUser->new()
   # fetch from profile service
   my $token = Bio::KBase::AuthToken->new( user_id => "mrbig", password => 'bigP@SSword');
   $user->get( token => $token->token );
   # $user's attributes should now be populated.

=head2 Caching

   This class implements a user profile cache that operates on a LRU algorithm. The default lifespan of a user profile in the cache is 10 minutes, but it can be set in ~/.kbase_config file to a different value. Note that while user profile information such as name, email and user_id are cached, group membership is not, this is to facilitate the timely updating of access control lists.

=head2 Class Variables

=over

=item B<%Conf>

This contains the configuration directives from the user's ~/.kbase_config under the section header "authentication". All the config settings can be accessed via $Bio::KBase::AuthUser::Conf{ 'authentication.SOMETHING'}

=item B<$VERSION>

This is the version string (pulled from the Bio::KBase::Auth module)

=item B<$ProfileCache>

This is a CSV formatted string that contains 3 fields: last seen time, hash key, value

The last seen time is the output from time() when the record was last request or loaded

The hash key is a salted SHA1 hash of the token used to acquire a user profile, 

The value is the base64 encoded JSON profile data retrieved from the profile service

When a profile entry has been expired due to TTL, the last seen value is set to 0 and the key and value are set to "_expired". Eventually this entry will be pushed out of the cache entirely as new profiles are pulled in.

The cache is searched and timestamps are updated using perl regex functions to achieve good performance. New entries are added and deleted using split(), sort() and join() for performance as well. When the Shared memory caching option is enabled ( with authentication.shm_cache in the config file), this string is tied into an IPC::Shareable memory region.

=item B<$ProfileCacheSize>

This integrer is maximum the number of profiles that are kept in the cache. Each time that a new profile is added, the entries are sorted in descending time order, and any entries above this number are dropped. This can be configured via the authentication.profile_cache_size directive.

=item B<$ProfileCacheTTL>

The number of seconds that a profile entry can remain in the cache since the last time it was accessed. Set with the authentication.profile_cache_ttl

=item B<$CacheKeySalt>

String used to salt the sha1 hash calculated for cache keys. Set using authentication.cache_salt

=back

=head2 Instance Variables

=over

=item B<user_id> (string)

Username/user_id for this user.

=item B<error_message> (string)

contains error messages, if any, from most recent method call

=item B<groups> (hashref)

A hash reference keyed on group names (value is simple 1) for storing Unix style groups that the user is a member of

=item B<oauth_creds> (hash)

reference to hash array keyed on consumer_keys that stores public keys, private keys, verifiers and tokens associated with this user

=item B<name> (string)

End-User's full name in displayable form including all name parts, ordered according to End-User's locale and preferences.

=item B<email> (string)

The End-User's preferred e-mail address.

=item B<verified> (boolean)

True if the End-User's e-mail address has been verified; otherwise false.

=back

=head2 Methods

=over

=item B<new>( [ token => token, user_id => user, groups => \[ 'group1', 'group2'], ...] )

returns a Bio::KBase::AuthUser reference. Parameters are a hash used to initialize a new user object. As a convenience, you can specify a field "token" and give it the value of an AuthToken, and the library will force it into the $self->oauth_creds->auth_token and then run the get() method to fetch the user record from the Globus Nexus service.

=item B<user_id>(string)

returns a string representing the user_id of the user in the AuthUser object

=item B<get>( [token => string, nocache => 0/1])

Returns $self. If given a token string as its only argument, fetch the user profile associated with
the token from Globus Nexus.

   Example:
   $token = "un=sychan|clientid=sychan|expiry=1376426267|SigningSubject=https://graph.api.go.sandbox.globuscs.info/goauth/keys/da0a4e96-e22a-11e1-9b09-1231381bc4c2|sig=8ef2ff2027b60165d5af12db70f5eba8f239fc42140de82ec262a8b4e525cc53a2866bc9da9efcf5faa893875ecea7fb5c7d3563f3f2dae48cbc0bd7dabaf2ce48e76ea0f755f15d7c1b24d8f9adf7dd0";

   $user = new Bio::KBase::AuthUser;
   $user->get( token => $token);

The AuthUser module implements caching of the user profiles, and if you want to bypass this caching set the nocache parameter to a true value.

=item B<update>( %new_attr_values)

Returns $self. Updates the user's profile if we have appropriate login credentials. Takes a hash list of profile attributes and updates those values on the profile service. Returns a reference to the updated AuthUser object. Note that the API supports arbitrary custom fields, so if you would like to add a new attribute to the user profile, simply call this with the appropriater hash/value parameters

   Example:
   # assuming we have a legit $token for the user
   $user = new Bio::KBase::AuthUser;
   $user->get( $token); # Get the user's record using the token
   $user->update( 'new_attribute' => 'new_value'); # Should be written to the backend service

=back

=cut
