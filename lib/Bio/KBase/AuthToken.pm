package Bio::KBase::AuthToken;

use Bio::KBase::AuthConstants ':all';

use strict;
use warnings;
use JSON;
use Bio::KBase::Auth;
use LWP::UserAgent;
use Digest::SHA1 qw(sha1_base64);
use Crypt::OpenSSL::RSA;
use Convert::PEM;
use MIME::Base64;
use URI;
use POSIX;
use DateTime;
use Bio::KBase::SSHAgent::Agent;

# We use Object::Tiny::RW to generate getters/setters for the attributes
# and save ourselves some tedium
use Object::Tiny::RW qw {
    error_message
    user_id
    password
    client_secret
    sshagent_keys
    sshagent_keyname
};

# Pull the INI files based configs in
# use a typeglob to alias it
our %Conf;
*Conf = \%Bio::KBase::Auth::AuthConf;

our $VERSION = $Bio::KBase::Auth::VERSION;

our @trust_token_signers = trust_token_signers;

# Tokens (last time we checked) had a 24 hour lifetime, this value can be
# used to add extra time to the lifetime of tokens. The unit is seconds.
# This can be be overridden  with a parameter passed into the validate() function.
our $token_lifetime = 0;
our @attrs = ( 'user_id', 'token','client_secret', 'keyfile',
	       'keyfile_passphrase','password','sshagent_keys',
	       'sshagent_keyname');

# Some hashes to cache tokens and Token Signers we have seen before
our $SignerCache;
our $SignerCacheSize = exists($Conf{'authentication.signer_cache_size'}) ?
                              $Conf{'authentication.signer_cache_size'} : 12;
# For long running processes, like a server, we use a fixed length cache
# to limit the number of entries we cache. The token cache only stores
# the user_id and sha1 of the token, and not the actual token
our $TokenCache;
our $TokenCacheSize = exists($Conf{'authentication.token_cache_size'}) ?
                             $Conf{'authentication.token_cache_size'} : 50;

# Pickup the cache hashing salt from configs
our $CacheKeySalt = exists($Conf{'authentication.cache_salt'}) ?
                           $Conf{'Authentication.cache_salt'} : "NaCl";

# If enabled, create some shared memory hashes for our cache.
# Make them only readable/writeable by ourselves
if ($Conf{'authentication.shm_cache'}) {
}

$TokenCache = "";
$SignerCache = "";

# This is the name of the environment variable that contains a
# pregenerated token
our $TokenEnv = exists($Conf{'authentication.tokenvar'}) ?
    $Conf{'authentication.tokenvar'} : "KB_AUTH_TOKEN";

# If we have a MongDB connection in the configs, bind $authz_db to it to , otherwise
# leave it undef. 
our $AuthzDB = undef;
if (defined $Conf{'authentication.authzdb'}) {

    eval {
	my $db = quotemeta( $Conf{'authentication.authzdb'} );
	if ( grep { /$db/ } $Bio::KBase::Auth::MongoDB->database_names() ) {
	    $AuthzDB = $Bio::KBase::Auth::MongoDB->get_database($Conf{'authentication.authzdb'});
	} else {
	    die "Database $db not found on ".$Conf{'authentication.mongodb'};
	}
    };
    if ($@) {
	printf STDERR "Error connecting to MongoDB database %s on %s: %s/nSessionID lookups are *not* enabled\n",
	$Conf{'authentication.authzdb'}, $Bio::KBase::Auth::MongoDB,
	$@;
	$AuthzDB = undef; # Should be undef already, just being paranoid
    }
}
    

# Your typical constructor - takes a hash that specifies the initial values to
# plug into the object.
# A special attribute is "ignore_kbase_config", if that it set then we will not bother
# trying to read the ~/.kbase_config file
sub new {
    my $class = shift;

    # Don't bother with calling the Object::Tiny::RW constructor,
    # since it doesn't do anything except return a blessed empty hash
    my $self = $class->SUPER::new(
        'token' => undef,
        'error_message' => undef,
        @_
    );

    eval {
	# make ignore_kbase_config an alias for ignore_authrc if it isn't specified
	if ( !exists( $self->{'ignore_kbase_config'}) &&
	     exists( $self->{'ignore_authrc'})) {
	    $self->{'ignore_kbase_config'} = $self->{'ignore_authrc'};
	}

	# Do we have any default attributes from the $Conf hash?
	my %c = %Bio::KBase::Auth::AuthConf;
	my $def_attr = scalar( grep { exists( $c{ 'authentication.'.$_}) } @attrs);
			    
	# Load any available ssh-agent keys into the sshagent_keys hash
	$self->get_agent_rsakeys();

	# If we were given a token, try set that using the formal setter
	# elsif we have appropriate login credentials, try to get a
	# token
	if ($self->{'token'}) {
	    $self->token( $self->{'token'});
	} elsif ($self->{'user_id'} && 
		 ($self->{'password'} || $self->{'client_secret'} || $self->{'keyfile'} || $self->{sshagent_keyname})) {
	    $self->get();
	} elsif ( defined( $ENV{$TokenEnv})) {
	    $self->token($ENV{$TokenEnv});
	} elsif (! $self->{'ignore_kbase_config'} && $def_attr ) {
	    # If we get a token, use that immediately and ignore the rest,
	    # otherwise set the other attributes and fetch the token
	    if (exists( $c{ 'authentication.token'})) {
		$self->token( $c{'authentication.token'});
		$self->validate();
	    } else {
		foreach my $attr ( @attrs) {
		    if (exists( $c{ 'authentication.'.$attr })) {
			$self->{ $attr } = $c{ 'authentication.'.$attr };
		    }
		}
		$self->get();
	    }
	}
    };
    if ($@) {
	$self->error_message("Failed to acquire token: $@");
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
	# Update last seen time
	my $now = time();
	$$cache =~ s/^$last,key:$key2/$now,key:$key/m;
	return($value);
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

# getter/setter for token, if we are given a token, parse it out
# and set the appropriate attributes 
sub token {
    my $self = shift @_;
    my $token = shift;

    unless( $token) {
	return( $self->{'token'});
    }

    # parse out token and set user_id
    eval {
	$self->{'token'} = $token;
	($self->{'user_id'}) = $token =~ /un=(\w+)/;
	unless ($self->{'user_id'}) {
	    # Could this be a sessionid hash?
	    unless ( $self->{token} =~ m/^[0-9a-fA-F]{64}$/) {
		die "Cannot parse user_id from token - illegal token";
	    }
	}
    };
    if ($@) {
	$self->error_message("Invalid token: $@");
	return( undef);
    } else {
	$self->{'error_message'} = undef;
	return( $token);
    }
}

# Get a nexus token, using either user_id, password or user_id, rsakey.
# Parameters looked for within $self:
# body => body of the http message, if any, can be undefined
# user_id => user name recognized on globus online for login
# client_id => user name recognized on globus online for login
# client_secret => the RSA private key used for signing
# password => Globus online password
# sshagent_name => the comment associated with the key in the ssh-agent to use for
#           authentication. Typically this is the path to the private key
# sshagent_name => the keyname associated with an ssh-agent loaded key. Must be a
#           a key in the $self->ssh_keys hash
# Throws an exception if either invalid set of creds or failed login

sub get {
    my $self = shift @_;
    my %p = @_;
    my $path = $Bio::KBase::Auth::AuthorizePath;
    my $url = $Bio::KBase::Auth::AuthSvcHost;
    my $method = "GET";
    my %headers;
    my $res;

    eval {
	# If we are given a path to a private key
	# try to load that, using a passphrase to decrypt if
	# provided
	if ( defined( $p{'keyfile'}) ) {
	    $self->{'keyfile'} = $p{'keyfile'};
	}						     
	if ( defined( $p{'keyfile_passphrase'}) ) {
	    $self->{'keyfile_passphrase'} = $p{'keyfile_passphrase'};
	}						     

	# read in the decrypted private key if it was specified
	if ( $self->{'keyfile'} ) {
	    if ($self->{'keyfile_passphrase'}) {
		$self->client_secret (decryptPEM( $self->{'keyfile'},
						  $self->{'keyfile_passphrase'}));
	    } else {
		open( KEY, $self->{'keyfile'});
		read( KEY, $self->{'client_secret'}, -s KEY);
		close( KEY);
	    }
	}

	if ($p{'user_id'}) {
	    $self->user_id($p{'user_id'});
	}

	# Note the side effect - if a client secret is explicitly specified, it
	# will override anything specified with the keyfile argument
	if ($p{'client_secret'}) {
	    $self->client_secret($p{'client_secret'});
	}
	if ($p{sshagent_keyname}) {
	    $self->{sshagent_keyname} = $p{sshagent_keyname};
	}
	if ($p{'password'}) {
	    $self->password($p{'password'});
	}

	# Make sure we have the right combo of creds
	if ($self->{'user_id'} && ($self->{'client_secret'} || $self->{'password'} || $self->{sshagent_keyname})) {
	    # no op
	} else {
	    die("Need either (user_id, client_secret || password || sshagent_keyname)  to be defined.");
	}
	
	my $u = URI->new($url);
	my %qparams = ("grant_type" => "client_credentials",
		       "client_id" => $self->{'client_id'} ? $self->{'client_id'} : $self->{'user_id'});
	$u->query_form( %qparams );
	my $query=$u->query();
	
	# Okay, if we have user_id/password, create a basic auth header and extract it
	# otherwise create a set of RSA signature headers using
	# user_id and client_secret
	my $headers;
	if ( $self->{'user_id'} && $self->{'password'}) {
	    $headers = HTTP::Headers->new;
	    $headers->authorization_basic( $self->{'user_id'}, $self->{'password'});
	    $headers{'Authorization'} = $headers->header('Authorization');
	} else {
	    my %p2 = ( path => $path,
		       method => $method,
		       user_id => $self->{'user_id'},
		       query => $query,
		       body => $self->{'body'} );
	    if ( $self->{client_secret}) {
		$p2{rsakey} = $self->{client_secret};
	    } else {
		$p2{agent} = $self->{sshagent};
		$p2{sshagent_keyname} = $self->{sshagent_keyname};
	    }
	    
	    %headers = sign_with_rsa( %p2);
	}
	my $path2 = sprintf('%s?%s',$path,$query);
	$res = $self->go_request( "path" => $path2, 'headers' => \%headers);
	unless ($res->{'access_token'}) {
	    die "No token returned by Globus Online";
	}
    };
    if ($@) {
	$self->{'token'} = undef;
	$self->{'user_id'} = undef;
	die "Failed to get auth token: $@";
    } else {
	return($self->token( $res->{'access_token'}));
    }
}

# The basic sha1_base64 does not properly pad the encoded text
# so we have this little wrapper to tack on extra '='.
sub sha1_base64_padded {
    my $in = shift;
    my @pad = ('','===','==','=');

    my $out = sha1_base64( $in);
    return ($out.$pad[length($out) % 4]);
}

# Return a hash of HTTP headers used by Globus Nexus to authenticate
# a token request.
sub sign_with_rsa {
    my %p = @_;
    my %headers;

    eval {
	# The sha1_base64 functions choke on an undefs, so
	# set body to an empty string if it is undef
	unless (defined($p{'body'})) {
	    $p{'body'} = "";
	}
	my $timestamp = canonical_time(time());
	%headers = ( 'X-Globus-UserId' => $p{user_id},
			'X-Globus-Sign'   => 'version=1.0',
			'X-Globus-Timestamp' => $timestamp,
	    );
	
	my $to_sign = join("\n",
			   "Method:%s",
			   "Hashed Path:%s",
			   "X-Globus-Content-Hash:%s",
			   "X-Globus-Query-Hash:%s",
			   "X-Globus-Timestamp:%s",
			   "X-Globus-UserId:%s");
	$to_sign = sprintf( $to_sign,
			    $p{method},
			    sha1_base64_padded($p{path}),
			    sha1_base64_padded($p{body}),
			    sha1_base64_padded($p{query}),
			    $timestamp,
			    $headers{'X-Globus-UserId'});
	# We can sign either with sshagent_keyname or with an explicit rsakey
	my $sig;
	my $key;
	if ( $p{rsakey} ) {
	    my $pkey = Crypt::OpenSSL::RSA->new_private_key($p{rsakey});
	    $pkey->use_sha1_hash();
	    $sig = $pkey->sign($to_sign);
	} elsif ( $p{sshagent_keyname} && $p{agent}) {
	    my $keys = $p{agent}->keys();
	    unless ($key = $keys->{$p{sshagent_keyname}}) {
		die( sprintf "Key %s was not found among ssh-agent keys.", $p{sshagent_keyname});
	    }
	    $sig = $p{agent}->sign_with_keyblob( $key, $to_sign);
	} else {
	    die "No RSA key specified";
	}

	my $sig_base64 = encode_base64( $sig);
	my @sig_base64 = split( '\n', $sig_base64);
	foreach my $x (0..$#sig_base64) {
	    $headers{ sprintf( 'X-Globus-Authorization-%s', $x)} = $sig_base64[$x];
	}
    };
    if ($@) {
	die "Could not sign headers: $@";
    } else {
	return(%headers);
    }
}

# Formats a time string in the format desired by Globus Online
# It is somewhat bogus, because they are claiming that it is
# UTC, when in fact its the localtime.           
sub canonical_time {
    my $time = shift;
    return( strftime("%Y-%m-%dT%H:%M:%S", localtime($time)) . 'Z');

}

# Function that returns if the token is valid or not
# optionally accepts hash as parameters
# If the token is a 64 byte hex string, then it treats it as
# a kbase_sessionid and will attempt to retrieve the actual token
# from a mongodb session collection. This only works if the
# sessiondb is enabled
#
# lifetime => seconds The number of seconds to use for token
#                     lifetime, overrides the class variable
#                     $token_lifetime 
sub validate {
    my $self = shift;
    my %p = @_;
    my $verify;
    my $tok_sha1;

    eval {
	unless ($self->{'token'}) {
	    die "No token.";
	}

	# Check for kbase session id, if found, fetch it and replace
	# the token with that value
	if ( $self->{token} =~ m/^[0-9a-fA-F]{64}$/ && $AuthzDB) {
	    my $token = get_sessDB_token( $self->{token});
	    unless ($token) {
		die "Session ID does not refer to a legitimate session";
	    }
	}
	my ($sig_data) = $self->{'token'} =~ /^(.*)\|sig=/;
	unless ($sig_data) {
	    die "Token lacks signature fields";
	}
	my %vars = map { split /=/ } split /\|/, $self->{'token'};
	unless (defined($p{'lifetime'})) {
	    $p{'lifetime'} = $token_lifetime;
	}
	unless (($vars{'expiry'} + $p{'lifetime'}) >= time) {
	    die "Token expired at: ".scalar( localtime($vars{'expiry'} + $p{'lifetime'})) ;
	}
	# As a sanity check, we are going to verify that the
	# signing subject has a URL that matches the URL for our
	# Globus Nexus Rest service. A token that is signed by someone
	# else isn't really that interesting to us.
	unless ( $vars{'SigningSubject'} =~ /^\Q$Bio::KBase::Auth::AuthSvcHost\E/) {
	    die "Token signed by unrecognized source: ".$vars{'SigningSubject'};
	}
	unless (length($vars{'sig'}) == 256) {
	    die "Token has malformed signature field";
	}
	# Check the token cache first
	my $cached = cache_get( \$TokenCache, $self->{'token'});
	if ( $cached && $cached eq $vars{'un'} ) {
	    $verify = 1;
	} else {
	    # Check cache for signer public key
	    my($response, $binary_sig, $client);
	    $binary_sig = pack('H*',$vars{'sig'});
	    my $data = cache_get( \$SignerCache, $vars{'SigningSubject'});
	    unless ($data) {
		$client = LWP::UserAgent->new();
		$client->ssl_opts(verify_hostname => 0);
		$client->timeout(5);
		$response = $client->get( $vars{'SigningSubject'});
		if ($response->is_success) {
		    $data = from_json( $response->content());
		    cache_set( \$SignerCache, $SignerCacheSize, $vars{'SigningSubject'}, encode_base64( $response->content(), ''));
		} else {
		    die "Failed to get signing subject: " . $response->status_line;
		}
	    } else {
		$data = from_json(decode_base64( $data));
	    }
	    $data = $self->_SquashJSONBool( $data);
	    unless ($data->{'valid'}) {
		die "Signing key is not valid:".$response->content();
	    }

	    my $rsa = Crypt::OpenSSL::RSA->new_public_key( $data->{'pubkey'});
	    $rsa->use_sha1_hash();

	    $verify = $rsa->verify($sig_data,$binary_sig);
	    if ($verify) {
		# write the sha1 hash of the token into the cache
		# we don't actually want to store the tokens themselves
		cache_set( \$TokenCache, $TokenCacheSize, $self->{'token'}, $vars{'un'});
	    }
	}
    };
    if ($@) {
	$self->error_message("Failed to verify token: $@");
	return( undef);
    } else {
	$self->{'error_message'} = $verify ? undef : "Token failed RSA signature verification";
	return( $verify);
    }
}

# function that handles Globus Online requests
# takes the following params in hash
# path => path/query part of the URL, doesn't include protocol/host
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
	my $baseurl = $Bio::KBase::Auth::AuthSvcHost;
	my %headers;
	unless ($p{'path'}) {
	    die "No path specified";
	}
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

# Code to read in an encrypted an openssh RSA private key file,
# cribbed shamelessly from http://www.indra.com/homepages/spike/stuff/openssl-rsa.html
#
# Returns the a decrypted private key if everything is good, throws an exception
# with the error message from Convert::PEM if not
#
sub decryptPEM {
  my ($file,$password) = @_;

  my $pem = Convert::PEM->new(
			      Name => 'RSA PRIVATE KEY',
			      ASN  => qq(
                  RSAPrivateKey SEQUENCE {
                      version INTEGER,
                      n INTEGER,
                      e INTEGER,
                      d INTEGER,
                      p INTEGER,
                      q INTEGER,
                      dp INTEGER,
                      dq INTEGER,
                      iqmp INTEGER
                  }
           ));


  my $pkey = $pem->read(Filename => $file, Password => $password);
  if ($pkey) {
      return($pem->encode(Content => $pkey));
  } else {
      die( "Failed to read private key: ".$pem->errstr());
  }
}

# Try to fetch the globus token associated with the session id passed
# in as the only param. If the session is expired, or the lookup fails,
# return undef

sub get_sessDB_token {
    my( $ssid) = shift @_;
    my( $session) = undef;

    my $token = undef;

    if ( $AuthzDB ) {
	$session = $AuthzDB->sessions->find_one( { kbase_sessionid => $ssid } );
	if ($session && DateTime->compare($session->{expiration}, DateTime->now()) <= 0) {
	    $token = $session->{token};
	}
    }
    return( $token);
}

# Check to see if we have an active ssh-agent session, and if so, examine the keys
# that are being stored, and return a hashref containing only the RSA keys. The hash
# is keyed on the comment for the key (ssh-agent seems to use the key's path as the
# comment) and the value is the 'key' handle that is returned. Note that the key handle
# is not actually the private key, but just a handle that can be passed back to ssh-agent
# when requesting that a private key operation be performed. Assumes that SSH_AUTH_SOCK and
# all that stuff is properly configured
sub get_agent_rsakeys {
    my( $self ) = shift;
    my( %p) = @_;
    my( $keys ) = {};

    unless ($self->{sshagent}) {
	$self->{sshagent} = Bio::KBase::SSHAgent::Agent->new(2);
    }
    
    # If the agent wasn't there, or there are no keys, just bail
    return $keys unless ($self->{sshagent} && $self->{sshagent}->num_identities()); 
    $keys = $self->{sshagent}->keys();
    # Walk through keys and delete any that aren't of type "ssh-rsa"
    foreach my $name ( keys %$keys) {
	my $key = $keys->{ $name };
	unless (substr($key,4,7) eq 'ssh-rsa') {
	    delete $keys->{$name};
	}
    }
    # if there is only a single RSA key, then make that the default
    # sshagent_keyname
    if (length(keys %$keys) == 1) {
	my @keys = keys %$keys;
	$self->{sshagent_keyname} = $keys[0];
    }
    return ($self->{sshagent_keys} = $keys);
}


1;

__END__

=pod

=head1 Bio::KBase::AuthToken

Token object for Globus Online/Globus Nexus tokens. For general information about Globus Nexus service see:
http://globusonline.github.com/nexus-docs/api.html


=head2 Examples

   # Acquiring a new token when you have username/password credentials
   my $token = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'password' => 'bigP@SSword');

   # or if you have an SSH private key for RSA authentication
   my $token2 = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'client_secret' => $rsakey);

   # or if you have an unencrypted token in the file $keyfile, you can use
   my $token3 = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'keyfile' => $keyfile);

   # or if you have a token in the file $keyfile, protected by passphrase "testing" 
   my $token3 = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'keyfile' => $keyfile,
                                            'keyfile_passphrase' => 'testing');

   # If you have a token in the shell environment variable $KB_AUTH_TOKEN you can
   # just instantiate an object with no parameters and it will use that as if it
   # were passed in as a token => %ENV{ KB_AUTH_TOKEN } among the params. This
   # will also work if there are no legit combinations of credential information
   # passed in
   my $tok = Bio::KBase::AuthToken->new( token => 'very long token string');
   # is the same as
   $ENV{ 'KB_AUTH_TOKEN'} = 'very long token string';
   my $tok = Bio::KBase::AuthToken->new()
   
   # any parameters for a credential/login that can be passed in to the new() method can
   # be put in the [authentication] section of the INI file specified in
   # $Bio::KBase::Auth::ConfPath ( defaults to ~/.kbase_config ) will be used to
   # initialize the object unless the ignore_kbase_config is set to a true value in the
   # call to new()
   # 
   # This is triggered by not providing any parameters to the new() method and not
   # having a $ENV{ KB_AUTH_TOKEN } defined.
   #
   # if ~/.kbase_config contains:
   # [authentication]
   # user_id=figaro
   # password=mamamia_mamamia
   #
   # Then the constructor will try to acquire a token with the user_id and password
   # settings provided.
   # Currently this library recognizes user_id, token,client_secret,keyfile,
   #	       keyfile_passphrase,password
   #
   # To login as jqpublic with an ssh key in ~jqpublic/.ssh/id_kbase that has the passphrase
   # "MostlySecret" you can set this in the .kbase_config file:
   # [authentication]
   # user_id=jqpublic
   # keyfile=/Users/jqpublic/.ssh/id_kbase
   # keyfile_passphrase=MostlySecret
   # 
   # and then execute the following
   my $token4 = Bio::KBase::AuthToken->new();

   # To disable this and just return an empty token object user
   my $token5 = Bio::KBase::AuthToken->new( ignore_kbase_config => 1 );

   # If you have a token in $tok, and wish to check if it is valid
   my $token3 = Bio::KBase::AuthToken->new( 'token' => $tok);
   if ($token3->validate()) {
       # token is legit
       my $user_id = $token3->user_id();

       # acquiring a full user profile once you have a token
       my $profile = new Bio::KBase::AuthUser->new;
       $profile->get( $token3->token());

   } else {
       die "Begone, evildoer!\n";
   }

=head2 Class Variables

=over

=item B<%Conf>

This contains the configuration directives from the user's ~/.kbase_config under the section header "authentication". All the config settings can be accessed via $Bio::KBase::AuthUser::Conf{ 'authentication.NAME'}, where NAME is found in the config file under the section heading "authentication".

=item B<@trust_token_signers>

An array that contains prefixes for trusted signing URLs in the SigningSubject field of tokens.

=item B<$token_lifetime>

Additional seconds to add to the expiration time of tokens. Tokens currently issued with a default 24 hour lifetime, but modifying this value will change when the validate() function will no longer accept the token. The units are in seconds.

=item B<@attrs>

List of strings that enumerate the attributes allowed to be read from the B<.kbase_config> file.

=item B<$VERSION>

This is the version string (pulled from the Bio::KBase::Auth module)

=item B<$TokenCache,$SignerCache>

These are CSV formatted strings for the Token and TokenSigner caches that contain 3 fields: last seen time, hash key, value

The last seen time is the output from time() when the record was last request or loaded

The hash key is a salted SHA1 hash of the token string (for the TokenCache) or the Signer URL (for the SignerCache)

The value is the username associated with the token (for TokenCache) or the JSON document at the Signer URL (for the SignerCache)

Entries are not expired due to any TTL, but are pushed out based on their last access time.

The cache is searched and timestamps are updated using perl regex functions to achieve good performance. New entries are added and deleted using split(), sort() and join() for performance as well. When the Shared memory caching option is enabled ( with authentication.shm_cache in the config file), this string is tied into an IPC::Shareable memory region.

=item B<$TokenCacheSize,$SignerCacheSize> integer

This is maximum the number of token validations or signer URL JSON docs that are kept in the cache. Each time that a new token/signer is added, the entries are sorted in descending time order, and any entries above this number are dropped. This can be configured via the authentication.token_cache_size and authentication.signer_cache_size directive.

=item B<$CacheKeySalt>

String used to salt the sha1 hash calculated for cache keys. Set using authentication.cache_salt

=item B<$TokenVar>

Shell environment variable that may contain a token to be used as a default token value, defaults to "KB_AUTH_TOKEN". This environment variable can be overridden by authentication.tokenvar in the .kbase_config file

=item B<$AuthzDB>

MongoDB::Database reference that is initialized by the authentication.authzdb value from the kbase_config file. The value in the configuration must refer to an existing database in the MongoDB instance referenced by $Bio::KBase::Auth::MongoDB. If authentication.authzdb is declared but the authentication.mongodb setting is invalid, or if the database does not exist, then an exception will be thrown at module load time. Do not set this unless you really know what you are doing.

=back

=head2 Instance Variables

=over

=item B<user_id> (string)

REQUIRED Userid of the associated with the token

=item B<token> (string)

A string containing a signed assertion from the Globus Nexus service. Here is an example:

un=sychan|clientid=sychan|expiry=1376425658|SigningSubject=https://graph.api.go.sandbox.globuscs.info/goauth/keys/da0a4e96-e22a-11e1-9b09-1231381bc4c2|sig=88cb32eae2782452817f106a2ce8cf9215f3356ce123d43395a5c99c5ec4184eaf5d70111124a06cf9267e5340f1d06b9258cf2e70e8000000000000000000000000000000583c68755de5453b4b019ebf3d7d4547778ef7d6322f2ba8f42d370bbce4b693ef7a9b3c7be3c6970132e72c654e3274afab9ea39ba9724383f1594

It is a series of name value pairs:

   un = username
   clientid = Globus Nexus client id
   expiry = time when the token was issued
   SigningSubject = url to the public key used to verify the signature
   sig = RSA sha1 signature hash

=item B<password> (string)

The password used to acquire token (if provided). Note that it is not possible to pull down the password from the authentication service.

=item B<client_secret> (string)

An unencrypted openssh formatted RSA private key string used for authentication

=item B<keyfile> (string)

File containing a B<client_secret> (typically something like ~user/.ssh/id_rsa). This must be readable by the effective UID of the running process. If the file contains an encrypted passphrase then the B<keyfile_passphrase> must also be specified. Private keys can be created using the ssh-keygen command (for example "ssh-keygen -t rsa -b 1024 -f kbase_rsa")

=item B<keyfile_passphrase> (string)

The passphrase used to decrypt the RSA private specified in B<keyfile>. See the ssh-keygen man page for information and setting/clering the passphrase.

=item B<sshagent_keys> (hashref keynames => ssh_agent_keys)

Hashref with keyname => rsa_sshkey pairs. The keyname is generated by ssh-agent and is the path to the private. Only RSA keys are exposed.

=item B<sshagent_keyname> (string)

String specifying which key in the sshagent to use for authentication. Must match one of the keys in sshagent_keys - format is typically the path to the private key

=item B<error_message> (string)

contains error messages, if any, from most recent method call.

=back

=head2 Methods

=over

=item B<new>()

returns a Bio::KBase::AuthToken reference. Optionally pass in hash params to initialize attributes. If we have enough attributes to perform a login either a token, or (user_id,password) or (user_id,client_secret) then the library will try to acquire a new token from Globus Nexus. If no parameters are given, then the library will look for a readable INI file in ~/.kbase_config and extract the attributes that match from @Bio::KBase::AuthToken::attrs into the new token an attempt to fetch a token from the Globus Online service. If you wish to short circuit the .kbase_config file, you can pass in a ignore_kbase_config => 1 as a parameter to new()

   Examples:

   # Acquiring a new token when you have username/password credentials
   my $token = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'password' => 'bigP@SSword');

   # or if you have an SSH private key in the string $rsakey

   my $token2 = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'client_secret' => $rsakey);

   # you have an rsa key in the file /home/mrbig/.ssh/id_rsa and wish to use it for authentication
   my $token3 = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'keyfile' => '/home/mrbig/.ssh/id_rsa');
   
   # Whoops, turns out it was encrypted
   my $token3 = Bio::KBase::AuthToken->new( 'user_id' => 'mrbig', 'keyfile' => '/home/mrbig/.ssh/id_rsa',
                                            'keyfile_passphrase' => 'L33Tp@55word');


=item B<user_id>()

returns the user_id associated with the token, if any. If a single string value is passed in, it will be used to set the value of the user_id

=item B<validate>()

attempts to verify the signature on the token, and returns a boolean value signifying whether the token is legit. If the value in the token attribute is a legitimate kbase session ID hash and a session database has been enabled (by the $AuthzDB database handle), the session ID will be replaced by the associated token, and then validated - this is only relevant for installations where the session service has been enabled.


=back

=cut
