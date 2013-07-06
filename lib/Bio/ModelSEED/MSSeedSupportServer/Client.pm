package Bio::ModelSEED::MSSeedSupportServer::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::ModelSEED::MSSeedSupportServer::Client

=head1 DESCRIPTION


=head1 MSSeedSupportServer

=head2 SYNOPSIS

=head2 EXAMPLE OF API USE IN PERL

=head2 AUTHENTICATION

=head2 MSSEEDSUPPORTSERVER


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::ModelSEED::MSSeedSupportServer::Client::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 getRastGenomeData

  $output = $obj->getRastGenomeData($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a getRastGenomeData_params
$output is a RastGenome
getRastGenomeData_params is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
	genome has a value which is a string
	getSequences has a value which is an int
	getDNASequence has a value which is an int
RastGenome is a reference to a hash where the following keys are defined:
	source has a value which is a string
	genome has a value which is a string
	features has a value which is a reference to a list where each element is a string
	DNAsequence has a value which is a reference to a list where each element is a string
	name has a value which is a string
	taxonomy has a value which is a string
	size has a value which is an int
	owner has a value which is a string

</pre>

=end html

=begin text

$params is a getRastGenomeData_params
$output is a RastGenome
getRastGenomeData_params is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
	genome has a value which is a string
	getSequences has a value which is an int
	getDNASequence has a value which is an int
RastGenome is a reference to a hash where the following keys are defined:
	source has a value which is a string
	genome has a value which is a string
	features has a value which is a reference to a list where each element is a string
	DNAsequence has a value which is a reference to a list where each element is a string
	name has a value which is a string
	taxonomy has a value which is a string
	size has a value which is an int
	owner has a value which is a string


=end text

=item Description

Retrieves a RAST genome based on the input genome ID

=back

=cut

sub getRastGenomeData
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getRastGenomeData (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getRastGenomeData:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getRastGenomeData');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MSSeedSupportServer.getRastGenomeData",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getRastGenomeData',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getRastGenomeData",
					    status_line => $self->{client}->status_line,
					    method_name => 'getRastGenomeData',
				       );
    }
}



=head2 get_user_info

  $output = $obj->get_user_info($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a get_user_info_params
$output is a SEEDUser
get_user_info_params is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
SEEDUser is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
	firstname has a value which is a string
	lastname has a value which is a string
	email has a value which is a string
	id has a value which is an int

</pre>

=end html

=begin text

$params is a get_user_info_params
$output is a SEEDUser
get_user_info_params is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
SEEDUser is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
	firstname has a value which is a string
	lastname has a value which is a string
	email has a value which is a string
	id has a value which is an int


=end text

=item Description

Retrieves a RAST genome based on the input genome ID

=back

=cut

sub get_user_info
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_user_info (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_user_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_user_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MSSeedSupportServer.get_user_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_user_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_user_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_user_info',
				       );
    }
}



=head2 authenticate

  $username = $obj->authenticate($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is an authenticate_params
$username is a string
authenticate_params is a reference to a hash where the following keys are defined:
	token has a value which is a string

</pre>

=end html

=begin text

$params is an authenticate_params
$username is a string
authenticate_params is a reference to a hash where the following keys are defined:
	token has a value which is a string


=end text

=item Description

Authenticate against the SEED account

=back

=cut

sub authenticate
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function authenticate (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to authenticate:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'authenticate');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MSSeedSupportServer.authenticate",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'authenticate',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method authenticate",
					    status_line => $self->{client}->status_line,
					    method_name => 'authenticate',
				       );
    }
}



=head2 load_model_to_modelseed

  $success = $obj->load_model_to_modelseed($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a load_model_to_modelseed_params
$success is an int
load_model_to_modelseed_params is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
	owner has a value which is a string
	genome has a value which is a string
	reactions has a value which is a reference to a list where each element is a string
	biomass has a value which is a string

</pre>

=end html

=begin text

$params is a load_model_to_modelseed_params
$success is an int
load_model_to_modelseed_params is a reference to a hash where the following keys are defined:
	username has a value which is a string
	password has a value which is a string
	owner has a value which is a string
	genome has a value which is a string
	reactions has a value which is a reference to a list where each element is a string
	biomass has a value which is a string


=end text

=item Description

Loads the input model to the model seed database

=back

=cut

sub load_model_to_modelseed
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function load_model_to_modelseed (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to load_model_to_modelseed:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'load_model_to_modelseed');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "MSSeedSupportServer.load_model_to_modelseed",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'load_model_to_modelseed',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method load_model_to_modelseed",
					    status_line => $self->{client}->status_line,
					    method_name => 'load_model_to_modelseed',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "MSSeedSupportServer.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'load_model_to_modelseed',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method load_model_to_modelseed",
            status_line => $self->{client}->status_line,
            method_name => 'load_model_to_modelseed',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::ModelSEED::MSSeedSupportServer::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::ModelSEED::MSSeedSupportServer::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 RastGenome

=over 4



=item Description

RAST genome data

        string source;
        string genome;
        list<string> features;
        list<string> DNAsequence;
        string name;
        string taxonomy;
        int size;
        string owner;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
source has a value which is a string
genome has a value which is a string
features has a value which is a reference to a list where each element is a string
DNAsequence has a value which is a reference to a list where each element is a string
name has a value which is a string
taxonomy has a value which is a string
size has a value which is an int
owner has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
source has a value which is a string
genome has a value which is a string
features has a value which is a reference to a list where each element is a string
DNAsequence has a value which is a reference to a list where each element is a string
name has a value which is a string
taxonomy has a value which is a string
size has a value which is an int
owner has a value which is a string


=end text

=back



=head2 getRastGenomeData_params

=over 4



=item Description

Input parameters for the "getRastGenomeData" function.

        string genome;
        int getSequences;
        int getDNASequence;
        string username;
        string password;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string
genome has a value which is a string
getSequences has a value which is an int
getDNASequence has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string
genome has a value which is a string
getSequences has a value which is an int
getDNASequence has a value which is an int


=end text

=back



=head2 SEEDUser

=over 4



=item Description

SEED user account

        string username;
    string password;
    string firstname;
    string lastname;
    string email;
    int id;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string
firstname has a value which is a string
lastname has a value which is a string
email has a value which is a string
id has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string
firstname has a value which is a string
lastname has a value which is a string
email has a value which is a string
id has a value which is an int


=end text

=back



=head2 get_user_info_params

=over 4



=item Description

Input parameters for the "get_user_info" function.

        string username;
        string password;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string


=end text

=back



=head2 authenticate_params

=over 4



=item Description

Input parameters for the "authenticate" function.

        string token;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
token has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
token has a value which is a string


=end text

=back



=head2 load_model_to_modelseed_params

=over 4



=item Description

Input parameters for the "load_model_to_modelseed" function.

        string token;


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string
owner has a value which is a string
genome has a value which is a string
reactions has a value which is a reference to a list where each element is a string
biomass has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
username has a value which is a string
password has a value which is a string
owner has a value which is a string
genome has a value which is a string
reactions has a value which is a reference to a list where each element is a string
biomass has a value which is a string


=end text

=back



=cut

package Bio::ModelSEED::MSSeedSupportServer::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;