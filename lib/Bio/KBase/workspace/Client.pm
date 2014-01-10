package Bio::KBase::workspace::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::workspace::Client

=head1 DESCRIPTION


The workspace service at its core is a storage and retrieval system for 
typed objects. Objects are organized by the user into one or more workspaces.

Features:

Versioning of objects
Data provenenance
Object to object references
Workspace sharing
**Add stuff here***

Notes about deletion and GC

BINARY DATA:
All binary data must be hex encoded prior to storage in a workspace. 
Attempting to send binary data via a workspace client will cause errors.


=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'http://kbase.us/services/workspace/';
    }

    my $self = {
	client => Bio::KBase::workspace::Client::RpcClient->new,
	url => $url,
    };

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 create_workspace

  $info = $obj->create_workspace($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.CreateWorkspaceParams
$info is a Workspace.workspace_info
CreateWorkspaceParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	globalread has a value which is a Workspace.permission
	description has a value which is a string
ws_name is a string
permission is a string
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
ws_id is an int
username is a string
timestamp is a string
lock_status is a string

</pre>

=end html

=begin text

$params is a Workspace.CreateWorkspaceParams
$info is a Workspace.workspace_info
CreateWorkspaceParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	globalread has a value which is a Workspace.permission
	description has a value which is a string
ws_name is a string
permission is a string
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
ws_id is an int
username is a string
timestamp is a string
lock_status is a string


=end text

=item Description

Creates a new workspace.

=back

=cut

sub create_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function create_workspace (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to create_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'create_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.create_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'create_workspace',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method create_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'create_workspace',
				       );
    }
}



=head2 clone_workspace

  $info = $obj->clone_workspace($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.CloneWorkspaceParams
$info is a Workspace.workspace_info
CloneWorkspaceParams is a reference to a hash where the following keys are defined:
	wsi has a value which is a Workspace.WorkspaceIdentity
	workspace has a value which is a Workspace.ws_name
	globalread has a value which is a Workspace.permission
	description has a value which is a string
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
permission is a string
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
lock_status is a string

</pre>

=end html

=begin text

$params is a Workspace.CloneWorkspaceParams
$info is a Workspace.workspace_info
CloneWorkspaceParams is a reference to a hash where the following keys are defined:
	wsi has a value which is a Workspace.WorkspaceIdentity
	workspace has a value which is a Workspace.ws_name
	globalread has a value which is a Workspace.permission
	description has a value which is a string
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
permission is a string
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
lock_status is a string


=end text

=item Description

Creates a new workspace.

=back

=cut

sub clone_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function clone_workspace (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to clone_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'clone_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.clone_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'clone_workspace',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method clone_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'clone_workspace',
				       );
    }
}



=head2 lock_workspace

  $info = $obj->lock_workspace($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$info is a Workspace.workspace_info
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
permission is a string
lock_status is a string

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$info is a Workspace.workspace_info
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
permission is a string
lock_status is a string


=end text

=item Description

Lock a workspace, preventing further changes.

        WARNING: Locking a workspace is permanent. A workspace, once locked,
        cannot be unlocked.
        
        The only changes allowed for a locked workspace are changing user
        based permissions or making a private workspace globally readable,
        thus permanently publishing the workspace. A locked, globally readable
        workspace cannot be made private.

=back

=cut

sub lock_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function lock_workspace (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to lock_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'lock_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.lock_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'lock_workspace',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method lock_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'lock_workspace',
				       );
    }
}



=head2 get_workspacemeta

  $metadata = $obj->get_workspacemeta($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.get_workspacemeta_params
$metadata is a Workspace.workspace_metadata
get_workspacemeta_params is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	auth has a value which is a string
ws_name is a string
ws_id is an int
workspace_metadata is a reference to a list containing 7 items:
	0: (id) a Workspace.ws_name
	1: (owner) a Workspace.username
	2: (moddate) a Workspace.timestamp
	3: (objects) an int
	4: (user_permission) a Workspace.permission
	5: (global_permission) a Workspace.permission
	6: (num_id) a Workspace.ws_id
username is a string
timestamp is a string
permission is a string

</pre>

=end html

=begin text

$params is a Workspace.get_workspacemeta_params
$metadata is a Workspace.workspace_metadata
get_workspacemeta_params is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	auth has a value which is a string
ws_name is a string
ws_id is an int
workspace_metadata is a reference to a list containing 7 items:
	0: (id) a Workspace.ws_name
	1: (owner) a Workspace.username
	2: (moddate) a Workspace.timestamp
	3: (objects) an int
	4: (user_permission) a Workspace.permission
	5: (global_permission) a Workspace.permission
	6: (num_id) a Workspace.ws_id
username is a string
timestamp is a string
permission is a string


=end text

=item Description

Retrieves the metadata associated with the specified workspace.
Provided for backwards compatibility. 
@deprecated Workspace.get_workspace_info

=back

=cut

sub get_workspacemeta
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_workspacemeta (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_workspacemeta:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_workspacemeta');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_workspacemeta",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_workspacemeta',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_workspacemeta",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_workspacemeta',
				       );
    }
}



=head2 get_workspace_info

  $info = $obj->get_workspace_info($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$info is a Workspace.workspace_info
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
permission is a string
lock_status is a string

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$info is a Workspace.workspace_info
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
permission is a string
lock_status is a string


=end text

=item Description

Get information associated with a workspace.

=back

=cut

sub get_workspace_info
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_workspace_info (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_workspace_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_workspace_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_workspace_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_workspace_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_workspace_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_workspace_info',
				       );
    }
}



=head2 get_workspace_description

  $description = $obj->get_workspace_description($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$description is a string
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$description is a string
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int


=end text

=item Description

Get a workspace's description.

=back

=cut

sub get_workspace_description
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_workspace_description (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_workspace_description:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_workspace_description');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_workspace_description",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_workspace_description',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_workspace_description",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_workspace_description',
				       );
    }
}



=head2 set_permissions

  $obj->set_permissions($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.SetPermissionsParams
SetPermissionsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	new_permission has a value which is a Workspace.permission
	users has a value which is a reference to a list where each element is a Workspace.username
ws_name is a string
ws_id is an int
permission is a string
username is a string

</pre>

=end html

=begin text

$params is a Workspace.SetPermissionsParams
SetPermissionsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	new_permission has a value which is a Workspace.permission
	users has a value which is a reference to a list where each element is a Workspace.username
ws_name is a string
ws_id is an int
permission is a string
username is a string


=end text

=item Description

Set permissions for a workspace.

=back

=cut

sub set_permissions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function set_permissions (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to set_permissions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'set_permissions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.set_permissions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'set_permissions',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method set_permissions",
					    status_line => $self->{client}->status_line,
					    method_name => 'set_permissions',
				       );
    }
}



=head2 set_global_permission

  $obj->set_global_permission($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.SetGlobalPermissionsParams
SetGlobalPermissionsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	new_permission has a value which is a Workspace.permission
ws_name is a string
ws_id is an int
permission is a string

</pre>

=end html

=begin text

$params is a Workspace.SetGlobalPermissionsParams
SetGlobalPermissionsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	new_permission has a value which is a Workspace.permission
ws_name is a string
ws_id is an int
permission is a string


=end text

=item Description

Set the global permission for a workspace.

=back

=cut

sub set_global_permission
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function set_global_permission (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to set_global_permission:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'set_global_permission');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.set_global_permission",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'set_global_permission',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method set_global_permission",
					    status_line => $self->{client}->status_line,
					    method_name => 'set_global_permission',
				       );
    }
}



=head2 set_workspace_description

  $obj->set_workspace_description($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.SetWorkspaceDescriptionParams
SetWorkspaceDescriptionParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	description has a value which is a string
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$params is a Workspace.SetWorkspaceDescriptionParams
SetWorkspaceDescriptionParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	description has a value which is a string
ws_name is a string
ws_id is an int


=end text

=item Description

Set the description for a workspace.

=back

=cut

sub set_workspace_description
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function set_workspace_description (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to set_workspace_description:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'set_workspace_description');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.set_workspace_description",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'set_workspace_description',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method set_workspace_description",
					    status_line => $self->{client}->status_line,
					    method_name => 'set_workspace_description',
				       );
    }
}



=head2 get_permissions

  $perms = $obj->get_permissions($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$perms is a reference to a hash where the key is a Workspace.username and the value is a Workspace.permission
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
username is a string
permission is a string

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$perms is a reference to a hash where the key is a Workspace.username and the value is a Workspace.permission
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
username is a string
permission is a string


=end text

=item Description

Get permissions for a workspace.

=back

=cut

sub get_permissions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_permissions (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_permissions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_permissions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_permissions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_permissions',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_permissions",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_permissions',
				       );
    }
}



=head2 save_object

  $metadata = $obj->save_object($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.save_object_params
$metadata is a Workspace.object_metadata
save_object_params is a reference to a hash where the following keys are defined:
	id has a value which is a Workspace.obj_name
	type has a value which is a Workspace.type_string
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	workspace has a value which is a Workspace.ws_name
	metadata has a value which is a reference to a hash where the key is a string and the value is a string
	auth has a value which is a string
obj_name is a string
type_string is a string
ws_name is a string
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int

</pre>

=end html

=begin text

$params is a Workspace.save_object_params
$metadata is a Workspace.object_metadata
save_object_params is a reference to a hash where the following keys are defined:
	id has a value which is a Workspace.obj_name
	type has a value which is a Workspace.type_string
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	workspace has a value which is a Workspace.ws_name
	metadata has a value which is a reference to a hash where the key is a string and the value is a string
	auth has a value which is a string
obj_name is a string
type_string is a string
ws_name is a string
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int


=end text

=item Description

Saves the input object data and metadata into the selected workspace,
        returning the object_metadata of the saved object. Provided
        for backwards compatibility.
        
@deprecated Workspace.save_objects

=back

=cut

sub save_object
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function save_object (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to save_object:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'save_object');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.save_object",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'save_object',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method save_object",
					    status_line => $self->{client}->status_line,
					    method_name => 'save_object',
				       );
    }
}



=head2 save_objects

  $info = $obj->save_objects($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.SaveObjectsParams
$info is a reference to a list where each element is a Workspace.object_info
SaveObjectsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData
ws_name is a string
ws_id is an int
ObjectSaveData is a reference to a hash where the following keys are defined:
	type has a value which is a Workspace.type_string
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	meta has a value which is a Workspace.usermeta
	provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
	hidden has a value which is a Workspace.boolean
type_string is a string
obj_name is a string
obj_id is an int
usermeta is a reference to a hash where the key is a string and the value is a string
ProvenanceAction is a reference to a hash where the following keys are defined:
	time has a value which is a Workspace.timestamp
	service has a value which is a string
	service_ver has a value which is a string
	method has a value which is a string
	method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	script has a value which is a string
	script_ver has a value which is a string
	script_command_line has a value which is a string
	input_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	resolved_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	intermediate_incoming has a value which is a reference to a list where each element is a string
	intermediate_outgoing has a value which is a reference to a list where each element is a string
	description has a value which is a string
timestamp is a string
obj_ref is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
username is a string

</pre>

=end html

=begin text

$params is a Workspace.SaveObjectsParams
$info is a reference to a list where each element is a Workspace.object_info
SaveObjectsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData
ws_name is a string
ws_id is an int
ObjectSaveData is a reference to a hash where the following keys are defined:
	type has a value which is a Workspace.type_string
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	meta has a value which is a Workspace.usermeta
	provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
	hidden has a value which is a Workspace.boolean
type_string is a string
obj_name is a string
obj_id is an int
usermeta is a reference to a hash where the key is a string and the value is a string
ProvenanceAction is a reference to a hash where the following keys are defined:
	time has a value which is a Workspace.timestamp
	service has a value which is a string
	service_ver has a value which is a string
	method has a value which is a string
	method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	script has a value which is a string
	script_ver has a value which is a string
	script_command_line has a value which is a string
	input_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	resolved_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	intermediate_incoming has a value which is a reference to a list where each element is a string
	intermediate_outgoing has a value which is a reference to a list where each element is a string
	description has a value which is a string
timestamp is a string
obj_ref is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
username is a string


=end text

=item Description

Save objects to the workspace. Saving over a deleted object undeletes
it.

=back

=cut

sub save_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function save_objects (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to save_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'save_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.save_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'save_objects',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method save_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'save_objects',
				       );
    }
}



=head2 get_object

  $output = $obj->get_object($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.get_object_params
$output is a Workspace.get_object_output
get_object_params is a reference to a hash where the following keys are defined:
	id has a value which is a Workspace.obj_name
	workspace has a value which is a Workspace.ws_name
	instance has a value which is an int
	auth has a value which is a string
obj_name is a string
ws_name is a string
get_object_output is a reference to a hash where the following keys are defined:
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	metadata has a value which is a Workspace.object_metadata
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int

</pre>

=end html

=begin text

$params is a Workspace.get_object_params
$output is a Workspace.get_object_output
get_object_params is a reference to a hash where the following keys are defined:
	id has a value which is a Workspace.obj_name
	workspace has a value which is a Workspace.ws_name
	instance has a value which is an int
	auth has a value which is a string
obj_name is a string
ws_name is a string
get_object_output is a reference to a hash where the following keys are defined:
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	metadata has a value which is a Workspace.object_metadata
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int


=end text

=item Description

Retrieves the specified object from the specified workspace.
Both the object data and metadata are returned.
Provided for backwards compatibility.

@deprecated Workspace.get_objects

=back

=cut

sub get_object
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_object (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_object:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_object');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_object",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_object',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_object",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_object',
				       );
    }
}



=head2 get_objects

  $data = $obj->get_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$data is a reference to a list where each element is a Workspace.ObjectData
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
ObjectData is a reference to a hash where the following keys are defined:
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	info has a value which is a Workspace.object_info
	provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
	creator has a value which is a Workspace.username
	created has a value which is a Workspace.timestamp
	refs has a value which is a reference to a list where each element is a Workspace.obj_ref
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
ProvenanceAction is a reference to a hash where the following keys are defined:
	time has a value which is a Workspace.timestamp
	service has a value which is a string
	service_ver has a value which is a string
	method has a value which is a string
	method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	script has a value which is a string
	script_ver has a value which is a string
	script_command_line has a value which is a string
	input_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	resolved_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	intermediate_incoming has a value which is a reference to a list where each element is a string
	intermediate_outgoing has a value which is a reference to a list where each element is a string
	description has a value which is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$data is a reference to a list where each element is a Workspace.ObjectData
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
ObjectData is a reference to a hash where the following keys are defined:
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	info has a value which is a Workspace.object_info
	provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
	creator has a value which is a Workspace.username
	created has a value which is a Workspace.timestamp
	refs has a value which is a reference to a list where each element is a Workspace.obj_ref
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
ProvenanceAction is a reference to a hash where the following keys are defined:
	time has a value which is a Workspace.timestamp
	service has a value which is a string
	service_ver has a value which is a string
	method has a value which is a string
	method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	script has a value which is a string
	script_ver has a value which is a string
	script_command_line has a value which is a string
	input_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	resolved_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
	intermediate_incoming has a value which is a reference to a list where each element is a string
	intermediate_outgoing has a value which is a reference to a list where each element is a string
	description has a value which is a string


=end text

=item Description

Get objects from the workspace.

=back

=cut

sub get_objects
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_objects',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_objects',
				       );
    }
}



=head2 get_object_history

  $history = $obj->get_object_history($object)

=over 4

=item Parameter and return types

=begin html

<pre>
$object is a Workspace.ObjectIdentity
$history is a reference to a list where each element is a Workspace.object_info
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$object is a Workspace.ObjectIdentity
$history is a reference to a list where each element is a Workspace.object_info
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Get an object's history. The version argument of the ObjectIdentity is
ignored.

=back

=cut

sub get_object_history
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_object_history (received $n, expecting 1)");
    }
    {
	my($object) = @args;

	my @_bad_arguments;
        (ref($object) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"object\" (value was \"$object\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_object_history:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_object_history');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_object_history",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_object_history',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_object_history",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_object_history',
				       );
    }
}



=head2 list_workspaces

  $workspaces = $obj->list_workspaces($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.list_workspaces_params
$workspaces is a reference to a list where each element is a Workspace.workspace_metadata
list_workspaces_params is a reference to a hash where the following keys are defined:
	auth has a value which is a string
	excludeGlobal has a value which is a Workspace.boolean
boolean is an int
workspace_metadata is a reference to a list containing 7 items:
	0: (id) a Workspace.ws_name
	1: (owner) a Workspace.username
	2: (moddate) a Workspace.timestamp
	3: (objects) an int
	4: (user_permission) a Workspace.permission
	5: (global_permission) a Workspace.permission
	6: (num_id) a Workspace.ws_id
ws_name is a string
username is a string
timestamp is a string
permission is a string
ws_id is an int

</pre>

=end html

=begin text

$params is a Workspace.list_workspaces_params
$workspaces is a reference to a list where each element is a Workspace.workspace_metadata
list_workspaces_params is a reference to a hash where the following keys are defined:
	auth has a value which is a string
	excludeGlobal has a value which is a Workspace.boolean
boolean is an int
workspace_metadata is a reference to a list containing 7 items:
	0: (id) a Workspace.ws_name
	1: (owner) a Workspace.username
	2: (moddate) a Workspace.timestamp
	3: (objects) an int
	4: (user_permission) a Workspace.permission
	5: (global_permission) a Workspace.permission
	6: (num_id) a Workspace.ws_id
ws_name is a string
username is a string
timestamp is a string
permission is a string
ws_id is an int


=end text

=item Description

Lists the metadata of all workspaces a user has access to. Provided for
backwards compatibility - to be replaced by the functionality of
list_workspace_info

@deprecated Workspace.list_workspace_info

=back

=cut

sub list_workspaces
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_workspaces (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_workspaces:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_workspaces');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_workspaces",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_workspaces',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_workspaces",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_workspaces',
				       );
    }
}



=head2 list_workspace_info

  $wsinfo = $obj->list_workspace_info($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.ListWorkspaceInfoParams
$wsinfo is a reference to a list where each element is a Workspace.workspace_info
ListWorkspaceInfoParams is a reference to a hash where the following keys are defined:
	excludeGlobal has a value which is a Workspace.boolean
	showDeleted has a value which is a Workspace.boolean
boolean is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
ws_id is an int
ws_name is a string
username is a string
timestamp is a string
permission is a string
lock_status is a string

</pre>

=end html

=begin text

$params is a Workspace.ListWorkspaceInfoParams
$wsinfo is a reference to a list where each element is a Workspace.workspace_info
ListWorkspaceInfoParams is a reference to a hash where the following keys are defined:
	excludeGlobal has a value which is a Workspace.boolean
	showDeleted has a value which is a Workspace.boolean
boolean is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
ws_id is an int
ws_name is a string
username is a string
timestamp is a string
permission is a string
lock_status is a string


=end text

=item Description

Early version of list_workspaces.

=back

=cut

sub list_workspace_info
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_workspace_info (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_workspace_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_workspace_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_workspace_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_workspace_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_workspace_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_workspace_info',
				       );
    }
}



=head2 list_workspace_objects

  $objects = $obj->list_workspace_objects($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.list_workspace_objects_params
$objects is a reference to a list where each element is a Workspace.object_metadata
list_workspace_objects_params is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	type has a value which is a Workspace.type_string
	showDeletedObject has a value which is a Workspace.boolean
	auth has a value which is a string
ws_name is a string
type_string is a string
boolean is an int
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
obj_name is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int

</pre>

=end html

=begin text

$params is a Workspace.list_workspace_objects_params
$objects is a reference to a list where each element is a Workspace.object_metadata
list_workspace_objects_params is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	type has a value which is a Workspace.type_string
	showDeletedObject has a value which is a Workspace.boolean
	auth has a value which is a string
ws_name is a string
type_string is a string
boolean is an int
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
obj_name is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int


=end text

=item Description

Lists the metadata of all objects in the specified workspace with the
specified type (or with any type). Provided for backwards compatibility.

@deprecated Workspace.list_objects

=back

=cut

sub list_workspace_objects
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_workspace_objects (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_workspace_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_workspace_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_workspace_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_workspace_objects',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_workspace_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_workspace_objects',
				       );
    }
}



=head2 list_objects

  $objinfo = $obj->list_objects($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.ListObjectsParams
$objinfo is a reference to a list where each element is a Workspace.object_info
ListObjectsParams is a reference to a hash where the following keys are defined:
	workspaces has a value which is a reference to a list where each element is a Workspace.ws_name
	ids has a value which is a reference to a list where each element is a Workspace.ws_id
	type has a value which is a Workspace.type_string
	showDeleted has a value which is a Workspace.boolean
	showHidden has a value which is a Workspace.boolean
	showAllVersions has a value which is a Workspace.boolean
	includeMetadata has a value which is a Workspace.boolean
ws_name is a string
ws_id is an int
type_string is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
obj_id is an int
obj_name is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a Workspace.ListObjectsParams
$objinfo is a reference to a list where each element is a Workspace.object_info
ListObjectsParams is a reference to a hash where the following keys are defined:
	workspaces has a value which is a reference to a list where each element is a Workspace.ws_name
	ids has a value which is a reference to a list where each element is a Workspace.ws_id
	type has a value which is a Workspace.type_string
	showDeleted has a value which is a Workspace.boolean
	showHidden has a value which is a Workspace.boolean
	showAllVersions has a value which is a Workspace.boolean
	includeMetadata has a value which is a Workspace.boolean
ws_name is a string
ws_id is an int
type_string is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
obj_id is an int
obj_name is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Early version of list_objects.

=back

=cut

sub list_objects
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_objects (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_objects',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_objects',
				       );
    }
}



=head2 get_objectmeta

  $metadata = $obj->get_objectmeta($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.get_objectmeta_params
$metadata is a Workspace.object_metadata
get_objectmeta_params is a reference to a hash where the following keys are defined:
	id has a value which is a Workspace.obj_name
	workspace has a value which is a Workspace.ws_name
	instance has a value which is an int
	auth has a value which is a string
obj_name is a string
ws_name is a string
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int

</pre>

=end html

=begin text

$params is a Workspace.get_objectmeta_params
$metadata is a Workspace.object_metadata
get_objectmeta_params is a reference to a hash where the following keys are defined:
	id has a value which is a Workspace.obj_name
	workspace has a value which is a Workspace.ws_name
	instance has a value which is an int
	auth has a value which is a string
obj_name is a string
ws_name is a string
object_metadata is a reference to a list containing 12 items:
	0: (id) a Workspace.obj_name
	1: (type) a Workspace.type_string
	2: (moddate) a Workspace.timestamp
	3: (instance) an int
	4: (command) a string
	5: (lastmodifier) a Workspace.username
	6: (owner) a Workspace.username
	7: (workspace) a Workspace.ws_name
	8: (ref) a string
	9: (chsum) a string
	10: (metadata) a Workspace.usermeta
	11: (objid) a Workspace.obj_id
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string
obj_id is an int


=end text

=item Description

Retrieves the metadata for a specified object from the specified
workspace. Provides access to metadata for all versions of the object
via the instance parameter. Provided for backwards compatibility.

@deprecated Workspace.get_object_info

=back

=cut

sub get_objectmeta
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_objectmeta (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_objectmeta:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_objectmeta');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_objectmeta",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_objectmeta',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_objectmeta",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_objectmeta',
				       );
    }
}



=head2 get_object_info

  $info = $obj->get_object_info($object_ids, $includeMetadata)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$includeMetadata is a Workspace.boolean
$info is a reference to a list where each element is a Workspace.object_info
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$includeMetadata is a Workspace.boolean
$info is a reference to a list where each element is a Workspace.object_info
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
boolean is an int
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Get information about an object from the workspace.

Set includeMetadata true to include the user specified metadata.
Otherwise the metadata in the object_info will be null.

=back

=cut

sub get_object_info
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_object_info (received $n, expecting 2)");
    }
    {
	my($object_ids, $includeMetadata) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        (!ref($includeMetadata)) or push(@_bad_arguments, "Invalid type for argument 2 \"includeMetadata\" (value was \"$includeMetadata\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_object_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_object_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_object_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_object_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_object_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_object_info',
				       );
    }
}



=head2 rename_workspace

  $renamed = $obj->rename_workspace($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.RenameWorkspaceParams
$renamed is a Workspace.workspace_info
RenameWorkspaceParams is a reference to a hash where the following keys are defined:
	wsi has a value which is a Workspace.WorkspaceIdentity
	new_name has a value which is a Workspace.ws_name
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
permission is a string
lock_status is a string

</pre>

=end html

=begin text

$params is a Workspace.RenameWorkspaceParams
$renamed is a Workspace.workspace_info
RenameWorkspaceParams is a reference to a hash where the following keys are defined:
	wsi has a value which is a Workspace.WorkspaceIdentity
	new_name has a value which is a Workspace.ws_name
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_info is a reference to a list containing 8 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (object) an int
	5: (user_permission) a Workspace.permission
	6: (globalread) a Workspace.permission
	7: (lockstat) a Workspace.lock_status
username is a string
timestamp is a string
permission is a string
lock_status is a string


=end text

=item Description

Rename a workspace.

=back

=cut

sub rename_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function rename_workspace (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to rename_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'rename_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.rename_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'rename_workspace',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method rename_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'rename_workspace',
				       );
    }
}



=head2 rename_object

  $renamed = $obj->rename_object($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.RenameObjectParams
$renamed is a Workspace.object_info
RenameObjectParams is a reference to a hash where the following keys are defined:
	obj has a value which is a Workspace.ObjectIdentity
	new_name has a value which is a Workspace.obj_name
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a Workspace.RenameObjectParams
$renamed is a Workspace.object_info
RenameObjectParams is a reference to a hash where the following keys are defined:
	obj has a value which is a Workspace.ObjectIdentity
	new_name has a value which is a Workspace.obj_name
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Rename an object. User meta data is always returned as null.

=back

=cut

sub rename_object
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function rename_object (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to rename_object:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'rename_object');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.rename_object",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'rename_object',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method rename_object",
					    status_line => $self->{client}->status_line,
					    method_name => 'rename_object',
				       );
    }
}



=head2 copy_object

  $copied = $obj->copy_object($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.CopyObjectParams
$copied is a Workspace.object_info
CopyObjectParams is a reference to a hash where the following keys are defined:
	from has a value which is a Workspace.ObjectIdentity
	to has a value which is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$params is a Workspace.CopyObjectParams
$copied is a Workspace.object_info
CopyObjectParams is a reference to a hash where the following keys are defined:
	from has a value which is a Workspace.ObjectIdentity
	to has a value which is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Copy an object. Returns the object_info for the newest version.

=back

=cut

sub copy_object
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function copy_object (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to copy_object:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'copy_object');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.copy_object",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'copy_object',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method copy_object",
					    status_line => $self->{client}->status_line,
					    method_name => 'copy_object',
				       );
    }
}



=head2 revert_object

  $reverted = $obj->revert_object($object)

=over 4

=item Parameter and return types

=begin html

<pre>
$object is a Workspace.ObjectIdentity
$reverted is a Workspace.object_info
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$object is a Workspace.ObjectIdentity
$reverted is a Workspace.object_info
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_info is a reference to a list containing 11 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (save_date) a Workspace.timestamp
	4: (version) an int
	5: (saved_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (workspace) a Workspace.ws_name
	8: (chsum) a string
	9: (size) an int
	10: (meta) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Revert an object.

        The object specified in the ObjectIdentity is reverted to the version
        specified in the ObjectIdentity.

=back

=cut

sub revert_object
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function revert_object (received $n, expecting 1)");
    }
    {
	my($object) = @args;

	my @_bad_arguments;
        (ref($object) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"object\" (value was \"$object\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to revert_object:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'revert_object');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.revert_object",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'revert_object',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method revert_object",
					    status_line => $self->{client}->status_line,
					    method_name => 'revert_object',
				       );
    }
}



=head2 hide_objects

  $obj->hide_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string


=end text

=item Description

Hide objects. All versions of an object are hidden, regardless of
the version specified in the ObjectIdentity. Hidden objects do not
appear in the list_objects method.

=back

=cut

sub hide_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function hide_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to hide_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'hide_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.hide_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'hide_objects',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method hide_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'hide_objects',
				       );
    }
}



=head2 unhide_objects

  $obj->unhide_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string


=end text

=item Description

Unhide objects. All versions of an object are unhidden, regardless
of the version specified in the ObjectIdentity.

=back

=cut

sub unhide_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function unhide_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to unhide_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'unhide_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.unhide_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'unhide_objects',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method unhide_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'unhide_objects',
				       );
    }
}



=head2 delete_objects

  $obj->delete_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string


=end text

=item Description

Delete objects. All versions of an object are deleted, regardless of
the version specified in the ObjectIdentity.

=back

=cut

sub delete_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.delete_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'delete_objects',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_objects',
				       );
    }
}



=head2 undelete_objects

  $obj->undelete_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string


=end text

=item Description

Undelete objects. All versions of an object are undeleted, regardless
of the version specified in the ObjectIdentity. If an object is not
deleted, no error is thrown.

=back

=cut

sub undelete_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function undelete_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to undelete_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'undelete_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.undelete_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'undelete_objects',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method undelete_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'undelete_objects',
				       );
    }
}



=head2 delete_workspace

  $obj->delete_workspace($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int


=end text

=item Description

Delete a workspace. All objects contained in the workspace are deleted.

=back

=cut

sub delete_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_workspace (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.delete_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'delete_workspace',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_workspace',
				       );
    }
}



=head2 undelete_workspace

  $obj->undelete_workspace($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int


=end text

=item Description

Undelete a workspace. All objects contained in the workspace are
undeleted, regardless of their state at the time the workspace was
deleted.

=back

=cut

sub undelete_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function undelete_workspace (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to undelete_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'undelete_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.undelete_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'undelete_workspace',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method undelete_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'undelete_workspace',
				       );
    }
}



=head2 request_module_ownership

  $obj->request_module_ownership($mod)

=over 4

=item Parameter and return types

=begin html

<pre>
$mod is a Workspace.modulename
modulename is a string

</pre>

=end html

=begin text

$mod is a Workspace.modulename
modulename is a string


=end text

=item Description

Request ownership of a module name. A Workspace administrator
must approve the request.

=back

=cut

sub request_module_ownership
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function request_module_ownership (received $n, expecting 1)");
    }
    {
	my($mod) = @args;

	my @_bad_arguments;
        (!ref($mod)) or push(@_bad_arguments, "Invalid type for argument 1 \"mod\" (value was \"$mod\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to request_module_ownership:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'request_module_ownership');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.request_module_ownership",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'request_module_ownership',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method request_module_ownership",
					    status_line => $self->{client}->status_line,
					    method_name => 'request_module_ownership',
				       );
    }
}



=head2 register_typespec

  $return = $obj->register_typespec($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.RegisterTypespecParams
$return is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
RegisterTypespecParams is a reference to a hash where the following keys are defined:
	spec has a value which is a Workspace.typespec
	mod has a value which is a Workspace.modulename
	new_types has a value which is a reference to a list where each element is a Workspace.typename
	remove_types has a value which is a reference to a list where each element is a Workspace.typename
	dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
	dryrun has a value which is a Workspace.boolean
	prev_ver has a value which is a Workspace.spec_version
typespec is a string
modulename is a string
typename is a string
spec_version is an int
boolean is an int
type_string is a string
jsonschema is a string

</pre>

=end html

=begin text

$params is a Workspace.RegisterTypespecParams
$return is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
RegisterTypespecParams is a reference to a hash where the following keys are defined:
	spec has a value which is a Workspace.typespec
	mod has a value which is a Workspace.modulename
	new_types has a value which is a reference to a list where each element is a Workspace.typename
	remove_types has a value which is a reference to a list where each element is a Workspace.typename
	dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
	dryrun has a value which is a Workspace.boolean
	prev_ver has a value which is a Workspace.spec_version
typespec is a string
modulename is a string
typename is a string
spec_version is an int
boolean is an int
type_string is a string
jsonschema is a string


=end text

=item Description

Register a new typespec or recompile a previously registered typespec
with new options.
See the documentation of RegisterTypespecParams for more details.
Also see the release_types function.

=back

=cut

sub register_typespec
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function register_typespec (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to register_typespec:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'register_typespec');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.register_typespec",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'register_typespec',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method register_typespec",
					    status_line => $self->{client}->status_line,
					    method_name => 'register_typespec',
				       );
    }
}



=head2 register_typespec_copy

  $new_local_version = $obj->register_typespec_copy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.RegisterTypespecCopyParams
$new_local_version is a Workspace.spec_version
RegisterTypespecCopyParams is a reference to a hash where the following keys are defined:
	external_workspace_url has a value which is a string
	mod has a value which is a Workspace.modulename
	version has a value which is a Workspace.spec_version
modulename is a string
spec_version is an int

</pre>

=end html

=begin text

$params is a Workspace.RegisterTypespecCopyParams
$new_local_version is a Workspace.spec_version
RegisterTypespecCopyParams is a reference to a hash where the following keys are defined:
	external_workspace_url has a value which is a string
	mod has a value which is a Workspace.modulename
	version has a value which is a Workspace.spec_version
modulename is a string
spec_version is an int


=end text

=item Description

Register a copy of new typespec or refresh an existing typespec which is
loaded from another workspace for synchronization. Method returns new
version of module in current workspace.

Also see the release_types function.

=back

=cut

sub register_typespec_copy
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function register_typespec_copy (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to register_typespec_copy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'register_typespec_copy');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.register_typespec_copy",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'register_typespec_copy',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method register_typespec_copy",
					    status_line => $self->{client}->status_line,
					    method_name => 'register_typespec_copy',
				       );
    }
}



=head2 release_module

  $types = $obj->release_module($mod)

=over 4

=item Parameter and return types

=begin html

<pre>
$mod is a Workspace.modulename
$types is a reference to a list where each element is a Workspace.type_string
modulename is a string
type_string is a string

</pre>

=end html

=begin text

$mod is a Workspace.modulename
$types is a reference to a list where each element is a Workspace.type_string
modulename is a string
type_string is a string


=end text

=item Description

Release a module for general use of its types.

Releases the most recent version of a module. Releasing a module does
two things to the module's types:
1) If a type's major version is 0, it is changed to 1. A major
        version of 0 implies that the type is in development and may have
        backwards incompatible changes from minor version to minor version.
        Once a type is released, backwards incompatible changes always
        cause a major version increment.
2) This version of the type becomes the default version, and if a 
        specific version is not supplied in a function call, this version
        will be used. This means that newer, unreleased versions of the
        type may be skipped.

=back

=cut

sub release_module
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function release_module (received $n, expecting 1)");
    }
    {
	my($mod) = @args;

	my @_bad_arguments;
        (!ref($mod)) or push(@_bad_arguments, "Invalid type for argument 1 \"mod\" (value was \"$mod\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to release_module:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'release_module');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.release_module",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'release_module',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method release_module",
					    status_line => $self->{client}->status_line,
					    method_name => 'release_module',
				       );
    }
}



=head2 list_modules

  $modules = $obj->list_modules($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.ListModulesParams
$modules is a reference to a list where each element is a Workspace.modulename
ListModulesParams is a reference to a hash where the following keys are defined:
	owner has a value which is a Workspace.username
username is a string
modulename is a string

</pre>

=end html

=begin text

$params is a Workspace.ListModulesParams
$modules is a reference to a list where each element is a Workspace.modulename
ListModulesParams is a reference to a hash where the following keys are defined:
	owner has a value which is a Workspace.username
username is a string
modulename is a string


=end text

=item Description

List typespec modules.

=back

=cut

sub list_modules
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_modules (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_modules:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_modules');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_modules",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_modules',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_modules",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_modules',
				       );
    }
}



=head2 list_module_versions

  $vers = $obj->list_module_versions($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.ListModuleVersionsParams
$vers is a Workspace.ModuleVersions
ListModuleVersionsParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	type has a value which is a Workspace.type_string
modulename is a string
type_string is a string
ModuleVersions is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	vers has a value which is a reference to a list where each element is a Workspace.spec_version
spec_version is an int

</pre>

=end html

=begin text

$params is a Workspace.ListModuleVersionsParams
$vers is a Workspace.ModuleVersions
ListModuleVersionsParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	type has a value which is a Workspace.type_string
modulename is a string
type_string is a string
ModuleVersions is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	vers has a value which is a reference to a list where each element is a Workspace.spec_version
spec_version is an int


=end text

=item Description

List typespec module versions.

=back

=cut

sub list_module_versions
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_module_versions (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_module_versions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_module_versions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_module_versions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_module_versions',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_module_versions",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_module_versions',
				       );
    }
}



=head2 get_module_info

  $info = $obj->get_module_info($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.GetModuleInfoParams
$info is a Workspace.ModuleInfo
GetModuleInfoParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	ver has a value which is a Workspace.spec_version
modulename is a string
spec_version is an int
ModuleInfo is a reference to a hash where the following keys are defined:
	owners has a value which is a reference to a list where each element is a Workspace.username
	ver has a value which is a Workspace.spec_version
	spec has a value which is a Workspace.typespec
	description has a value which is a string
	types has a value which is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
	included_spec_version has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
	chsum has a value which is a string
	functions has a value which is a reference to a list where each element is a Workspace.func_string
	is_released has a value which is a Workspace.boolean
username is a string
typespec is a string
type_string is a string
jsonschema is a string
func_string is a string
boolean is an int

</pre>

=end html

=begin text

$params is a Workspace.GetModuleInfoParams
$info is a Workspace.ModuleInfo
GetModuleInfoParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	ver has a value which is a Workspace.spec_version
modulename is a string
spec_version is an int
ModuleInfo is a reference to a hash where the following keys are defined:
	owners has a value which is a reference to a list where each element is a Workspace.username
	ver has a value which is a Workspace.spec_version
	spec has a value which is a Workspace.typespec
	description has a value which is a string
	types has a value which is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
	included_spec_version has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
	chsum has a value which is a string
	functions has a value which is a reference to a list where each element is a Workspace.func_string
	is_released has a value which is a Workspace.boolean
username is a string
typespec is a string
type_string is a string
jsonschema is a string
func_string is a string
boolean is an int


=end text

=item Description



=back

=cut

sub get_module_info
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_module_info (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_module_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_module_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_module_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_module_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_module_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_module_info',
				       );
    }
}



=head2 get_jsonschema

  $schema = $obj->get_jsonschema($type)

=over 4

=item Parameter and return types

=begin html

<pre>
$type is a Workspace.type_string
$schema is a Workspace.jsonschema
type_string is a string
jsonschema is a string

</pre>

=end html

=begin text

$type is a Workspace.type_string
$schema is a Workspace.jsonschema
type_string is a string
jsonschema is a string


=end text

=item Description

Get JSON schema for a type.

=back

=cut

sub get_jsonschema
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_jsonschema (received $n, expecting 1)");
    }
    {
	my($type) = @args;

	my @_bad_arguments;
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 1 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_jsonschema:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_jsonschema');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_jsonschema",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_jsonschema',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_jsonschema",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_jsonschema',
				       );
    }
}



=head2 translate_from_MD5_types

  $sem_types = $obj->translate_from_MD5_types($md5_types)

=over 4

=item Parameter and return types

=begin html

<pre>
$md5_types is a reference to a list where each element is a Workspace.type_string
$sem_types is a reference to a hash where the key is a Workspace.type_string and the value is a reference to a list where each element is a Workspace.type_string
type_string is a string

</pre>

=end html

=begin text

$md5_types is a reference to a list where each element is a Workspace.type_string
$sem_types is a reference to a hash where the key is a Workspace.type_string and the value is a reference to a list where each element is a Workspace.type_string
type_string is a string


=end text

=item Description

Translation from types qualified with MD5 to their semantic versions

=back

=cut

sub translate_from_MD5_types
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function translate_from_MD5_types (received $n, expecting 1)");
    }
    {
	my($md5_types) = @args;

	my @_bad_arguments;
        (ref($md5_types) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"md5_types\" (value was \"$md5_types\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to translate_from_MD5_types:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'translate_from_MD5_types');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.translate_from_MD5_types",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'translate_from_MD5_types',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method translate_from_MD5_types",
					    status_line => $self->{client}->status_line,
					    method_name => 'translate_from_MD5_types',
				       );
    }
}



=head2 translate_to_MD5_types

  $md5_types = $obj->translate_to_MD5_types($sem_types)

=over 4

=item Parameter and return types

=begin html

<pre>
$sem_types is a reference to a list where each element is a Workspace.type_string
$md5_types is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.type_string
type_string is a string

</pre>

=end html

=begin text

$sem_types is a reference to a list where each element is a Workspace.type_string
$md5_types is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.type_string
type_string is a string


=end text

=item Description

Translation from types qualified with semantic versions to their MD5'ed versions

=back

=cut

sub translate_to_MD5_types
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function translate_to_MD5_types (received $n, expecting 1)");
    }
    {
	my($sem_types) = @args;

	my @_bad_arguments;
        (ref($sem_types) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"sem_types\" (value was \"$sem_types\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to translate_to_MD5_types:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'translate_to_MD5_types');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.translate_to_MD5_types",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'translate_to_MD5_types',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method translate_to_MD5_types",
					    status_line => $self->{client}->status_line,
					    method_name => 'translate_to_MD5_types',
				       );
    }
}



=head2 get_type_info

  $info = $obj->get_type_info($type)

=over 4

=item Parameter and return types

=begin html

<pre>
$type is a Workspace.type_string
$info is a Workspace.TypeInfo
type_string is a string
TypeInfo is a reference to a hash where the following keys are defined:
	type_def has a value which is a Workspace.type_string
	description has a value which is a string
	spec_def has a value which is a string
	module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
	type_vers has a value which is a reference to a list where each element is a Workspace.type_string
	using_func_defs has a value which is a reference to a list where each element is a Workspace.func_string
	using_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
	used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
spec_version is an int
func_string is a string

</pre>

=end html

=begin text

$type is a Workspace.type_string
$info is a Workspace.TypeInfo
type_string is a string
TypeInfo is a reference to a hash where the following keys are defined:
	type_def has a value which is a Workspace.type_string
	description has a value which is a string
	spec_def has a value which is a string
	module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
	type_vers has a value which is a reference to a list where each element is a Workspace.type_string
	using_func_defs has a value which is a reference to a list where each element is a Workspace.func_string
	using_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
	used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
spec_version is an int
func_string is a string


=end text

=item Description



=back

=cut

sub get_type_info
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_type_info (received $n, expecting 1)");
    }
    {
	my($type) = @args;

	my @_bad_arguments;
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 1 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_type_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_type_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_type_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_type_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_type_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_type_info',
				       );
    }
}



=head2 get_func_info

  $info = $obj->get_func_info($func)

=over 4

=item Parameter and return types

=begin html

<pre>
$func is a Workspace.func_string
$info is a Workspace.FuncInfo
func_string is a string
FuncInfo is a reference to a hash where the following keys are defined:
	func_def has a value which is a Workspace.func_string
	description has a value which is a string
	spec_def has a value which is a string
	module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
	func_vers has a value which is a reference to a list where each element is a Workspace.func_string
	used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
spec_version is an int
type_string is a string

</pre>

=end html

=begin text

$func is a Workspace.func_string
$info is a Workspace.FuncInfo
func_string is a string
FuncInfo is a reference to a hash where the following keys are defined:
	func_def has a value which is a Workspace.func_string
	description has a value which is a string
	spec_def has a value which is a string
	module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
	func_vers has a value which is a reference to a list where each element is a Workspace.func_string
	used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
spec_version is an int
type_string is a string


=end text

=item Description



=back

=cut

sub get_func_info
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_func_info (received $n, expecting 1)");
    }
    {
	my($func) = @args;

	my @_bad_arguments;
        (!ref($func)) or push(@_bad_arguments, "Invalid type for argument 1 \"func\" (value was \"$func\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_func_info:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_func_info');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_func_info",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_func_info',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_func_info",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_func_info',
				       );
    }
}



=head2 administer

  $response = $obj->administer($command)

=over 4

=item Parameter and return types

=begin html

<pre>
$command is an UnspecifiedObject, which can hold any non-null object
$response is an UnspecifiedObject, which can hold any non-null object

</pre>

=end html

=begin text

$command is an UnspecifiedObject, which can hold any non-null object
$response is an UnspecifiedObject, which can hold any non-null object


=end text

=item Description

The administration interface.

=back

=cut

sub administer
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function administer (received $n, expecting 1)");
    }
    {
	my($command) = @args;

	my @_bad_arguments;
        (defined $command) or push(@_bad_arguments, "Invalid type for argument 1 \"command\" (value was \"$command\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to administer:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'administer');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.administer",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'administer',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method administer",
					    status_line => $self->{client}->status_line,
					    method_name => 'administer',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "Workspace.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'administer',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method administer",
            status_line => $self->{client}->status_line,
            method_name => 'administer',
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
        warn "New client version available for Bio::KBase::workspace::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::workspace::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

A boolean. 0 = false, other = true.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ws_id

=over 4



=item Description

The unique, permanent numerical ID of a workspace.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ws_name

=over 4



=item Description

A string used as a name for a workspace.
Any string consisting of alphanumeric characters and "_" that is not an
integer is acceptable. The name may optionally be prefixed with the
workspace owner's user name and a colon, e.g. kbasetest:my_workspace.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 permission

=over 4



=item Description

Represents the permissions a user or users have to a workspace:

        'a' - administrator. All operations allowed.
        'w' - read/write.
        'r' - read.
        'n' - no permissions.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 username

=over 4



=item Description

Login name of a KBase user account.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 timestamp

=over 4



=item Description

A time in the format YYYY-MM-DDThh:mm:ssZ, where Z is the difference
in time to UTC in the format +/-HHMM, eg:
        2012-12-17T23:24:06-0500 (EST time)
        2013-04-03T08:56:32+0000 (UTC time)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 type_string

=over 4



=item Description

A type string.
Specifies the type and its version in a single string in the format
[module].[typename]-[major].[minor]:

module - a string. The module name of the typespec containing the type.
typename - a string. The name of the type as assigned by the typedef
        statement.
major - an integer. The major version of the type. A change in the
        major version implies the type has changed in a non-backwards
        compatible way.
minor - an integer. The minor version of the type. A change in the
        minor version implies that the type has changed in a way that is
        backwards compatible with previous type definitions.

In many cases, the major and minor versions are optional, and if not
provided the most recent version will be used.

Example: MyModule.MyType-3.1


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 usermeta

=over 4



=item Description

User provided metadata about an object.
Arbitrary key-value pairs provided by the user.


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 lock_status

=over 4



=item Description

The lock status of a workspace.
One of 'unlocked', 'locked', or 'published'.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 WorkspaceIdentity

=over 4



=item Description

A workspace identifier.

                Select a workspace by one, and only one, of the numerical id or name,
                        where the name can also be a KBase ID including the numerical id,
                        e.g. kb|ws.35.
                ws_id id - the numerical ID of the workspace.
                ws_name workspace - name of the workspace or the workspace ID in KBase
                        format, e.g. kb|ws.78.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id


=end text

=back



=head2 workspace_metadata

=over 4



=item Description

Meta data associated with a workspace. Provided for backwards
compatibility. To be replaced by workspace_info.
        
ws_name id - name of the workspace 
username owner - name of the user who owns (who created) this object
timestamp moddate - date when the workspace was last modified
int objects - the approximate number of objects currently stored in
        the workspace.
permission user_permission - permissions for the currently logged in
        user for the workspace
permission global_permission - default permissions for the workspace
        for all KBase users
ws_id num_id - numerical ID of the workspace

@deprecated Workspace.workspace_info


=item Definition

=begin html

<pre>
a reference to a list containing 7 items:
0: (id) a Workspace.ws_name
1: (owner) a Workspace.username
2: (moddate) a Workspace.timestamp
3: (objects) an int
4: (user_permission) a Workspace.permission
5: (global_permission) a Workspace.permission
6: (num_id) a Workspace.ws_id

</pre>

=end html

=begin text

a reference to a list containing 7 items:
0: (id) a Workspace.ws_name
1: (owner) a Workspace.username
2: (moddate) a Workspace.timestamp
3: (objects) an int
4: (user_permission) a Workspace.permission
5: (global_permission) a Workspace.permission
6: (num_id) a Workspace.ws_id


=end text

=back



=head2 workspace_info

=over 4



=item Description

Information about a workspace.

        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace.
        username owner - name of the user who owns (e.g. created) this workspace.
        timestamp moddate - date when the workspace was last modified.
        int objects - the approximate number of objects currently stored in
                the workspace.
        permission user_permission - permissions for the authenticated user of
                this workspace.
        permission globalread - whether this workspace is globally readable.


=item Definition

=begin html

<pre>
a reference to a list containing 8 items:
0: (id) a Workspace.ws_id
1: (workspace) a Workspace.ws_name
2: (owner) a Workspace.username
3: (moddate) a Workspace.timestamp
4: (object) an int
5: (user_permission) a Workspace.permission
6: (globalread) a Workspace.permission
7: (lockstat) a Workspace.lock_status

</pre>

=end html

=begin text

a reference to a list containing 8 items:
0: (id) a Workspace.ws_id
1: (workspace) a Workspace.ws_name
2: (owner) a Workspace.username
3: (moddate) a Workspace.timestamp
4: (object) an int
5: (user_permission) a Workspace.permission
6: (globalread) a Workspace.permission
7: (lockstat) a Workspace.lock_status


=end text

=back



=head2 obj_id

=over 4



=item Description

The unique, permanent numerical ID of an object.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 obj_name

=over 4



=item Description

A string used as a name for an object.
Any string consisting of alphanumeric characters and the characters
        |._- that is not an integer is acceptable.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 obj_ver

=over 4



=item Description

An object version.
The version of the object, starting at 1.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 obj_ref

=over 4



=item Description

A string that uniquely identifies an object in the workspace service.

        There are two ways to uniquely identify an object in one string:
        "[ws_name or id]/[obj_name or id]/[obj_ver]" - for example,
                "MyFirstWorkspace/MyFirstObject/3" would identify the third version
                of an object called MyFirstObject in the workspace called
                MyFirstWorkspace. 42/Panic/1 would identify the first version of
                the object name Panic in workspace with id 42. Towel/1/6 would
                identify the 6th version of the object with id 1 in the Towel
                workspace. 
        "kb|ws.[ws_id].obj.[obj_id].ver.[obj_ver]" - for example, 
                "kb|ws.23.obj.567.ver.2" would identify the second version of an
                object with id 567 in a workspace with id 23.
        In all cases, if the version number is omitted, the latest version of
        the object is assumed.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ObjectIdentity

=over 4



=item Description

An object identifier.

Select an object by either:
        One, and only one, of the numerical id or name of the workspace,
        where the name can also be a KBase ID including the numerical id,
        e.g. kb|ws.35.
                ws_id wsid - the numerical ID of the workspace.
                ws_name workspace - name of the workspace or the workspace ID
                        in KBase format, e.g. kb|ws.78.
        AND 
        One, and only one, of the numerical id or name of the object.
                obj_id objid- the numerical ID of the object.
                obj_name name - name of the object.
        OPTIONALLY
                obj_ver ver - the version of the object.
OR an object reference string:
        obj_ref ref - an object reference string.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
wsid has a value which is a Workspace.ws_id
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
ver has a value which is a Workspace.obj_ver
ref has a value which is a Workspace.obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
wsid has a value which is a Workspace.ws_id
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
ver has a value which is a Workspace.obj_ver
ref has a value which is a Workspace.obj_ref


=end text

=back



=head2 object_metadata

=over 4



=item Description

Meta data associated with an object stored in a workspace. Provided for
backwards compatibility.
        
obj_name id - name of the object.
type_string type - type of the object.
timestamp moddate - date when the object was saved
obj_ver instance - the version of the object
string command - Deprecated. Always returns the empty string.
username lastmodifier - name of the user who last saved the object,
        including copying the object
username owner - Deprecated. Same as lastmodifier.
ws_name workspace - name of the workspace in which the object is
        stored
string ref - Deprecated. Always returns the empty string.
string chsum - the md5 checksum of the object.
usermeta metadata - arbitrary user-supplied metadata about
        the object.
obj_id objid - the numerical id of the object.


=item Definition

=begin html

<pre>
a reference to a list containing 12 items:
0: (id) a Workspace.obj_name
1: (type) a Workspace.type_string
2: (moddate) a Workspace.timestamp
3: (instance) an int
4: (command) a string
5: (lastmodifier) a Workspace.username
6: (owner) a Workspace.username
7: (workspace) a Workspace.ws_name
8: (ref) a string
9: (chsum) a string
10: (metadata) a Workspace.usermeta
11: (objid) a Workspace.obj_id

</pre>

=end html

=begin text

a reference to a list containing 12 items:
0: (id) a Workspace.obj_name
1: (type) a Workspace.type_string
2: (moddate) a Workspace.timestamp
3: (instance) an int
4: (command) a string
5: (lastmodifier) a Workspace.username
6: (owner) a Workspace.username
7: (workspace) a Workspace.ws_name
8: (ref) a string
9: (chsum) a string
10: (metadata) a Workspace.usermeta
11: (objid) a Workspace.obj_id


=end text

=back



=head2 object_info

=over 4



=item Description

Information about an object, including user provided metadata.

        obj_id objid - the numerical id of the object.
        obj_name name - the name of the object.
        type_string type - the type of the object.
        timestamp save_date - the save date of the object.
        obj_ver ver - the version of the object.
        username saved_by - the user that saved or copied the object.
        ws_id wsid - the workspace containing the object.
        ws_name workspace - the workspace containing the object.
        string chsum - the md5 checksum of the object.
        int size - the size of the object in bytes.
        usermeta meta - arbitrary user-supplied metadata about
                the object.


=item Definition

=begin html

<pre>
a reference to a list containing 11 items:
0: (objid) a Workspace.obj_id
1: (name) a Workspace.obj_name
2: (type) a Workspace.type_string
3: (save_date) a Workspace.timestamp
4: (version) an int
5: (saved_by) a Workspace.username
6: (wsid) a Workspace.ws_id
7: (workspace) a Workspace.ws_name
8: (chsum) a string
9: (size) an int
10: (meta) a Workspace.usermeta

</pre>

=end html

=begin text

a reference to a list containing 11 items:
0: (objid) a Workspace.obj_id
1: (name) a Workspace.obj_name
2: (type) a Workspace.type_string
3: (save_date) a Workspace.timestamp
4: (version) an int
5: (saved_by) a Workspace.username
6: (wsid) a Workspace.ws_id
7: (workspace) a Workspace.ws_name
8: (chsum) a string
9: (size) an int
10: (meta) a Workspace.usermeta


=end text

=back



=head2 ProvenanceAction

=over 4



=item Description

A provenance action.

        A provenance action is an action taken while transforming one data
        object to another. There may be several provenance actions taken in
        series. An action is typically running a script, running an api
        command, etc. All of the following are optional, but more information
        provided equates to better data provenance.
        
        resolved_ws_objects should never be set by the user; it is set by the
        workspace service when returning data.
        
        The maximum size of the entire provenance object, including all actions,
        is 1MB.
        
        timestamp time - the time the action was started.
        string service - the name of the service that performed this action.
        string service_ver - the version of the service that performed this action.
        string method - the method of the service that performed this action.
        list<UnspecifiedObject> method_params - the parameters of the method
                that performed this action. If an object in the parameters is a
                workspace object, also put the object reference in the
                input_ws_object list.
        string script - the name of the script that performed this action.
        string script_ver - the version of the script that performed this action.
        string script_command_line - the command line provided to the script
                that performed this action. If workspace objects were provided in
                the command line, also put the object reference in the
                input_ws_object list.
        list<obj_ref> input_ws_objects - the workspace objects that
                were used as input to this action; typically these will also be
                present as parts of the method_params or the script_command_line
                arguments.
        list<obj_ref> resolved_ws_objects - the workspace objects ids from 
                input_ws_objects resolved to permanent workspace object references
                by the workspace service.
        list<string> intermediate_incoming - if the previous action produced 
                output that 1) was not stored in a referrable way, and 2) is
                used as input for this action, provide it with an arbitrary and
                unique ID here, in the order of the input arguments to this action.
                These IDs can be used in the method_params argument.
        list<string> intermediate_outgoing - if this action produced output
                that 1) was not stored in a referrable way, and 2) is
                used as input for the next action, provide it with an arbitrary and
                unique ID here, in the order of the output values from this action.
                These IDs can be used in the intermediate_incoming argument in the
                next action.
        string description - a free text description of this action.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
time has a value which is a Workspace.timestamp
service has a value which is a string
service_ver has a value which is a string
method has a value which is a string
method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
script has a value which is a string
script_ver has a value which is a string
script_command_line has a value which is a string
input_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
resolved_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
intermediate_incoming has a value which is a reference to a list where each element is a string
intermediate_outgoing has a value which is a reference to a list where each element is a string
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
time has a value which is a Workspace.timestamp
service has a value which is a string
service_ver has a value which is a string
method has a value which is a string
method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
script has a value which is a string
script_ver has a value which is a string
script_command_line has a value which is a string
input_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
resolved_ws_objects has a value which is a reference to a list where each element is a Workspace.obj_ref
intermediate_incoming has a value which is a reference to a list where each element is a string
intermediate_outgoing has a value which is a reference to a list where each element is a string
description has a value which is a string


=end text

=back



=head2 CreateWorkspaceParams

=over 4



=item Description

Input parameters for the "create_workspace" function.

        Required arguments:
        ws_name workspace - name of the workspace to be created.
        
        Optional arguments:
        permission globalread - 'r' to set the new workspace globally readable,
                default 'n'.
        string description - A free-text description of the new workspace, 1000
                characters max. Longer strings will be mercilessly and brutally
                truncated.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
globalread has a value which is a Workspace.permission
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
globalread has a value which is a Workspace.permission
description has a value which is a string


=end text

=back



=head2 CloneWorkspaceParams

=over 4



=item Description

Input parameters for the "clone_workspace" function.

        Note that deleted objects are not cloned, although hidden objects are
        and remain hidden in the new workspace.

        Required arguments:
        WorkspaceIdentity wsi - the workspace to be cloned.
        ws_name workspace - name of the workspace to be cloned into. This must
                be a non-existant workspace name.
        
        Optional arguments:
        permission globalread - 'r' to set the new workspace globally readable,
                default 'n'.
        string description - A free-text description of the new workspace, 1000
                characters max. Longer strings will be mercilessly and brutally
                truncated.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
wsi has a value which is a Workspace.WorkspaceIdentity
workspace has a value which is a Workspace.ws_name
globalread has a value which is a Workspace.permission
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
wsi has a value which is a Workspace.WorkspaceIdentity
workspace has a value which is a Workspace.ws_name
globalread has a value which is a Workspace.permission
description has a value which is a string


=end text

=back



=head2 get_workspacemeta_params

=over 4



=item Description

Input parameters for the "get_workspacemeta" function. Provided for
backwards compatibility.
        
One, and only one of:
ws_name workspace - name of the workspace or the workspace ID in KBase
        format, e.g. kb|ws.78.
ws_id id - the numerical ID of the workspace.
        
Optional arguments:
string auth - the authentication token of the KBase account accessing
        the list of workspaces. Overrides the client provided authorization
        credentials if they exist.

@deprecated Workspace.WorkspaceIdentity


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
auth has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
auth has a value which is a string


=end text

=back



=head2 SetPermissionsParams

=over 4



=item Description

Input parameters for the "set_permissions" function.

        One, and only one, of the following is required:
        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace or the workspace ID in KBase
                format, e.g. kb|ws.78.
        
        Required arguments:
        permission new_permission - the permission to assign to the users.
        list<username> users - the users whose permissions will be altered.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
new_permission has a value which is a Workspace.permission
users has a value which is a reference to a list where each element is a Workspace.username

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
new_permission has a value which is a Workspace.permission
users has a value which is a reference to a list where each element is a Workspace.username


=end text

=back



=head2 SetGlobalPermissionsParams

=over 4



=item Description

Input parameters for the "set_global_permission" function.

        One, and only one, of the following is required:
        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace or the workspace ID in KBase
                format, e.g. kb|ws.78.
        
        Required arguments:
        permission new_permission - the permission to assign to all users,
                either 'n' or 'r'. 'r' means that all users will be able to read
                the workspace; otherwise users must have specific permission to
                access the workspace.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
new_permission has a value which is a Workspace.permission

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
new_permission has a value which is a Workspace.permission


=end text

=back



=head2 SetWorkspaceDescriptionParams

=over 4



=item Description

Input parameters for the "set_workspace_description" function.

        One, and only one, of the following is required:
        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace or the workspace ID in KBase
                format, e.g. kb|ws.78.
        
        Optional arguments:
        string description - A free-text description of the workspace, 1000
                characters max. Longer strings will be mercilessly and brutally
                truncated. If omitted, the description is set to null.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
description has a value which is a string


=end text

=back



=head2 save_object_params

=over 4



=item Description

Input parameters for the "save_object" function. Provided for backwards
compatibility.
        
Required arguments:
type_string type - type of the object to be saved
ws_name workspace - name of the workspace where the object is to be
        saved
obj_name id - name behind which the object will be saved in the
        workspace
UnspecifiedObject data - datastructure to be saved in the workspace

Optional arguments:
usermeta metadata - a hash of metadata to be associated with the object
string auth - the authentication token of the KBase account accessing
        the list of workspaces. Overrides the client provided authorization
        credentials if they exist.

@deprecated


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a Workspace.obj_name
type has a value which is a Workspace.type_string
data has a value which is an UnspecifiedObject, which can hold any non-null object
workspace has a value which is a Workspace.ws_name
metadata has a value which is a reference to a hash where the key is a string and the value is a string
auth has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a Workspace.obj_name
type has a value which is a Workspace.type_string
data has a value which is an UnspecifiedObject, which can hold any non-null object
workspace has a value which is a Workspace.ws_name
metadata has a value which is a reference to a hash where the key is a string and the value is a string
auth has a value which is a string


=end text

=back



=head2 ObjectSaveData

=over 4



=item Description

An object and associated data required for saving.

        Required arguments:
        type_string type - the type of the object. Omit the version information
                to use the latest version.
        UnspecifiedObject data - the object data.
        
        Optional arguments:
        One of an object name or id. If no name or id is provided the name
                will be set to 'auto' with the object id appended as a string,
                possibly with -\d+ appended if that object id already exists as a
                name.
        obj_name name - the name of the object.
        obj_id objid - the id of the object to save over.
        usermeta meta - arbitrary user-supplied metadata for the object,
                not to exceed 16kb.
        list<ProvenanceAction> provenance - provenance data for the object.
        boolean hidden - true if this object should not be listed when listing
                workspace objects.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
type has a value which is a Workspace.type_string
data has a value which is an UnspecifiedObject, which can hold any non-null object
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
meta has a value which is a Workspace.usermeta
provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
hidden has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
type has a value which is a Workspace.type_string
data has a value which is an UnspecifiedObject, which can hold any non-null object
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
meta has a value which is a Workspace.usermeta
provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
hidden has a value which is a Workspace.boolean


=end text

=back



=head2 SaveObjectsParams

=over 4



=item Description

Input parameters for the "save_objects" function.

        One, and only one, of the following is required:
        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace or the workspace ID in KBase
                format, e.g. kb|ws.78.
        
        Required arguments:
        list<ObjectSaveData> objects - the objects to save.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData


=end text

=back



=head2 get_object_params

=over 4



=item Description

Input parameters for the "get_object" function. Provided for backwards
compatibility.
        
Required arguments:
ws_name workspace - Name of the workspace containing the object to be
        retrieved
obj_name id - Name of the object to be retrieved

Optional arguments:
int instance - Version of the object to be retrieved, enabling
        retrieval of any previous version of an object
string auth - the authentication token of the KBase account accessing
        the list of workspaces. Overrides the client provided authorization
        credentials if they exist.

@deprecated Workspace.ObjectIdentity


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a Workspace.obj_name
workspace has a value which is a Workspace.ws_name
instance has a value which is an int
auth has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a Workspace.obj_name
workspace has a value which is a Workspace.ws_name
instance has a value which is an int
auth has a value which is a string


=end text

=back



=head2 get_object_output

=over 4



=item Description

Output generated by the "get_object" function. Provided for backwards
compatibility.
        
UnspecifiedObject data - The object's data.
object_metadata metadata - Metadata for object retrieved/
        
@deprecated Workspaces.ObjectData


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
data has a value which is an UnspecifiedObject, which can hold any non-null object
metadata has a value which is a Workspace.object_metadata

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
data has a value which is an UnspecifiedObject, which can hold any non-null object
metadata has a value which is a Workspace.object_metadata


=end text

=back



=head2 ObjectData

=over 4



=item Description

The data and supplemental info for an object.

        UnspecifiedObject data - the object's data.
        object_info info - information about the object.
        list<ProvenanceAction> provenance - the object's provenance.
        username creator - the user that first saved the object to the
                workspace.
        timestamp created - the date the object was first saved to the
                workspace.
        list<obj_ref> - the references contained within the object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
data has a value which is an UnspecifiedObject, which can hold any non-null object
info has a value which is a Workspace.object_info
provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
creator has a value which is a Workspace.username
created has a value which is a Workspace.timestamp
refs has a value which is a reference to a list where each element is a Workspace.obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
data has a value which is an UnspecifiedObject, which can hold any non-null object
info has a value which is a Workspace.object_info
provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
creator has a value which is a Workspace.username
created has a value which is a Workspace.timestamp
refs has a value which is a reference to a list where each element is a Workspace.obj_ref


=end text

=back



=head2 list_workspaces_params

=over 4



=item Description

Input parameters for the "list_workspaces" function. Provided for
backwards compatibility.

Optional parameters:
string auth - the authentication token of the KBase account accessing
        the list of workspaces. Overrides the client provided authorization
        credentials if they exist.
boolean excludeGlobal - if excludeGlobal is true exclude world
        readable workspaces. Defaults to false.

@deprecated Workspace.ListWorkspaceInfoParams


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
auth has a value which is a string
excludeGlobal has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
auth has a value which is a string
excludeGlobal has a value which is a Workspace.boolean


=end text

=back



=head2 ListWorkspaceInfoParams

=over 4



=item Description

Input parameters for the "list_workspace_info" function.

Optional parameters:
boolean excludeGlobal - if excludeGlobal is true exclude world
        readable workspaces. Defaults to false.
boolean showDeleted - show deleted workspaces that are owned by the
        user.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
excludeGlobal has a value which is a Workspace.boolean
showDeleted has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
excludeGlobal has a value which is a Workspace.boolean
showDeleted has a value which is a Workspace.boolean


=end text

=back



=head2 list_workspace_objects_params

=over 4



=item Description

Input parameters for the "list_workspace_objects" function. Provided
for backwards compatibility.

Required arguments:
ws_name workspace - Name of the workspace for which objects should be
        listed

Optional arguments:
type_string type - type of the objects to be listed. Here, omitting
        version information will find any objects that match the provided
        type - e.g. Foo.Bar-0 will match Foo.Bar-0.X where X is any
        existing version.
boolean showDeletedObject - show objects that have been deleted
string auth - the authentication token of the KBase account requesting
        access. Overrides the client provided authorization credentials if
        they exist.
        
@deprecated Workspaces.ListWorkspaceInfoParams


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
type has a value which is a Workspace.type_string
showDeletedObject has a value which is a Workspace.boolean
auth has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
type has a value which is a Workspace.type_string
showDeletedObject has a value which is a Workspace.boolean
auth has a value which is a string


=end text

=back



=head2 ListObjectsParams

=over 4



=item Description

Parameters for the 'list_objects' function.

                At least one of the following filters must be provided. It is strongly
                recommended that the list is restricted to the workspaces of interest,
                or the results may be very large:
                list<ws_id> ids - the numerical IDs of the workspaces of interest.
                list<ws_name> workspaces - name of the workspaces of interest or the
                        workspace IDs in KBase format, e.g. kb|ws.78.
                type_string type - type of the objects to be listed.  Here, omitting
                        version information will find any objects that match the provided
                        type - e.g. Foo.Bar-0 will match Foo.Bar-0.X where X is any
                        existing version.
                
                Optional arguments:
                boolean showDeleted - show deleted objects in workspaces to which the
                        user has write access.
                boolean showHidden - show hidden objects.
                boolean showAllVersions - show all versions of each object that match
                        the filters rather than only the most recent version.
                boolean includeMetadata - include the user provided metadata in the
                        returned object_info. If false (0 or null), the default, the
                        metadata will be null.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspaces has a value which is a reference to a list where each element is a Workspace.ws_name
ids has a value which is a reference to a list where each element is a Workspace.ws_id
type has a value which is a Workspace.type_string
showDeleted has a value which is a Workspace.boolean
showHidden has a value which is a Workspace.boolean
showAllVersions has a value which is a Workspace.boolean
includeMetadata has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspaces has a value which is a reference to a list where each element is a Workspace.ws_name
ids has a value which is a reference to a list where each element is a Workspace.ws_id
type has a value which is a Workspace.type_string
showDeleted has a value which is a Workspace.boolean
showHidden has a value which is a Workspace.boolean
showAllVersions has a value which is a Workspace.boolean
includeMetadata has a value which is a Workspace.boolean


=end text

=back



=head2 get_objectmeta_params

=over 4



=item Description

Input parameters for the "get_objectmeta" function.

        Required arguments:
        ws_name workspace - name of the workspace containing the object for
                 which metadata is to be retrieved
        obj_name id - name of the object for which metadata is to be retrieved
        
        Optional arguments:
        int instance - Version of the object for which metadata is to be
                 retrieved, enabling retrieval of any previous version of an object
        string auth - the authentication token of the KBase account requesting
                access. Overrides the client provided authorization credentials if
                they exist.
                
        @deprecated Workspace.ObjectIdentity


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a Workspace.obj_name
workspace has a value which is a Workspace.ws_name
instance has a value which is an int
auth has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a Workspace.obj_name
workspace has a value which is a Workspace.ws_name
instance has a value which is an int
auth has a value which is a string


=end text

=back



=head2 RenameWorkspaceParams

=over 4



=item Description

Input parameters for the 'rename_workspace' function.

Required arguments:
WorkspaceIdentity wsi - the workspace to rename.
ws_name new_name - the new name for the workspace.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
wsi has a value which is a Workspace.WorkspaceIdentity
new_name has a value which is a Workspace.ws_name

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
wsi has a value which is a Workspace.WorkspaceIdentity
new_name has a value which is a Workspace.ws_name


=end text

=back



=head2 RenameObjectParams

=over 4



=item Description

Input parameters for the 'rename_object' function.

Required arguments:
ObjectIdentity obj - the object to rename.
obj_name new_name - the new name for the object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
obj has a value which is a Workspace.ObjectIdentity
new_name has a value which is a Workspace.obj_name

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
obj has a value which is a Workspace.ObjectIdentity
new_name has a value which is a Workspace.obj_name


=end text

=back



=head2 CopyObjectParams

=over 4



=item Description

Input parameters for the 'copy_object' function. 

        If the 'from' ObjectIdentity includes no version and the object is
        copied to a new name, the entire version history of the object is
        copied. In all other cases only the version specified, or the latest
        version if no version is specified, is copied.
        
        The version from the 'to' ObjectIdentity is always ignored.
        
        Required arguments:
        ObjectIdentity from - the object to copy.
        ObjectIdentity to - where to copy the object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
from has a value which is a Workspace.ObjectIdentity
to has a value which is a Workspace.ObjectIdentity

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
from has a value which is a Workspace.ObjectIdentity
to has a value which is a Workspace.ObjectIdentity


=end text

=back



=head2 typespec

=over 4



=item Description

A type specification (typespec) file in the KBase Interface Description
Language (KIDL).


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 modulename

=over 4



=item Description

A module name defined in a KIDL typespec.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 typename

=over 4



=item Description

A type definition name in a KIDL typespec.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 func_string

=over 4



=item Description

A function string for referencing a funcdef.
Specifies the function and its version in a single string in the format
[modulename].[funcname]-[major].[minor]:

modulename - a string. The name of the module containing the function.
funcname - a string. The name of the function as assigned by the funcdef
        statement.
major - an integer. The major version of the function. A change in the
        major version implies the function has changed in a non-backwards
        compatible way.
minor - an integer. The minor version of the function. A change in the
        minor version implies that the function has changed in a way that is
        backwards compatible with previous function definitions.

In many cases, the major and minor versions are optional, and if not
provided the most recent version will be used.

Example: MyModule.MyFunc-3.1


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 spec_version

=over 4



=item Description

The version of a typespec file.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 jsonschema

=over 4



=item Description

The JSON Schema (v4) representation of a type definition.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 RegisterTypespecParams

=over 4



=item Description

Parameters for the register_typespec function.

        Required arguments:
        One of:
         typespec spec - the new typespec to register.
         modulename mod - the module to recompile with updated options (see below).
        
        Optional arguments:
        boolean dryrun - Return, but do not save, the results of compiling the 
                spec. Default true. Set to false for making permanent changes.
        list<typename> new_types - types in the spec to make available in the
                workspace service. When compiling a spec for the first time, if
                this argument is empty no types will be made available. Previously
                available types remain so upon recompilation of a spec or
                compilation of a new spec.
        list<typename> remove_types - no longer make these types available in
                the workspace service for the new version of the spec. This does
                not remove versions of types previously compiled.
        mapping<modulename, spec_version> dependencies - By default, the
                latest released versions of spec dependencies will be included when
                compiling a spec. Specific versions can be specified here.
        spec_version prev_ver - the id of the previous version of the typespec.
                An error will be thrown if this is set and prev_ver is not the
                most recent version of the typespec. This prevents overwriting of
                changes made since retrieving a spec and compiling an edited spec.
                This argument is ignored if a modulename is passed.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
spec has a value which is a Workspace.typespec
mod has a value which is a Workspace.modulename
new_types has a value which is a reference to a list where each element is a Workspace.typename
remove_types has a value which is a reference to a list where each element is a Workspace.typename
dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
dryrun has a value which is a Workspace.boolean
prev_ver has a value which is a Workspace.spec_version

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
spec has a value which is a Workspace.typespec
mod has a value which is a Workspace.modulename
new_types has a value which is a reference to a list where each element is a Workspace.typename
remove_types has a value which is a reference to a list where each element is a Workspace.typename
dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
dryrun has a value which is a Workspace.boolean
prev_ver has a value which is a Workspace.spec_version


=end text

=back



=head2 RegisterTypespecCopyParams

=over 4



=item Description

Parameters for the register_typespec_copy function.

        Required arguments:
        string external_workspace_url - the URL of the  workspace server from
                which to copy a typespec.
        modulename mod - the name of the module in the workspace server
        
        Optional arguments:
        spec_version version - the version of the module in the workspace
                server


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
external_workspace_url has a value which is a string
mod has a value which is a Workspace.modulename
version has a value which is a Workspace.spec_version

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
external_workspace_url has a value which is a string
mod has a value which is a Workspace.modulename
version has a value which is a Workspace.spec_version


=end text

=back



=head2 ListModulesParams

=over 4



=item Description

Parameters for the list_modules() function.

        Optional arguments:
        username owner - only list modules owned by this user.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
owner has a value which is a Workspace.username

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
owner has a value which is a Workspace.username


=end text

=back



=head2 ListModuleVersionsParams

=over 4



=item Description

Parameters for the list_module_versions function.

        Required arguments:
        One of:
        modulename mod - returns all versions of the module.
        type_string type - returns all versions of the module associated with
                the type.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
type has a value which is a Workspace.type_string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
type has a value which is a Workspace.type_string


=end text

=back



=head2 ModuleVersions

=over 4



=item Description

A set of versions from a module.

        modulename mod - the name of the module.
        list<spec_version> - a set or subset of versions associated with the
                module.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
vers has a value which is a reference to a list where each element is a Workspace.spec_version

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
vers has a value which is a reference to a list where each element is a Workspace.spec_version


=end text

=back



=head2 GetModuleInfoParams

=over 4



=item Description

Parameters for the get_module_info function.

        Required arguments:
        modulename mod - the name of the module to retrieve.
        
        Optional arguments:
        spec_version ver - the version of the module to retrieve. Defaults to
                the latest version.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
ver has a value which is a Workspace.spec_version

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
ver has a value which is a Workspace.spec_version


=end text

=back



=head2 ModuleInfo

=over 4



=item Description

Information about a module.

        list<username> owners - the owners of the module.
        spec_version ver - the version of the module.
        typespec spec - the typespec.
        string description - the description of the module from the typespec.
        mapping<type_string, jsonschema> types - the types associated with this
                module and their JSON schema.
        mapping<modulename, spec_version> included_spec_version - names of 
                included modules associated with their versions.
        string chsum - the md5 checksum of the object.
        list<func_string> functions - list of names of functions registered in spec.
        boolean is_released - shows if this version of module was released (and
                hence can be seen by others).


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
owners has a value which is a reference to a list where each element is a Workspace.username
ver has a value which is a Workspace.spec_version
spec has a value which is a Workspace.typespec
description has a value which is a string
types has a value which is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
included_spec_version has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
chsum has a value which is a string
functions has a value which is a reference to a list where each element is a Workspace.func_string
is_released has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
owners has a value which is a reference to a list where each element is a Workspace.username
ver has a value which is a Workspace.spec_version
spec has a value which is a Workspace.typespec
description has a value which is a string
types has a value which is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
included_spec_version has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
chsum has a value which is a string
functions has a value which is a reference to a list where each element is a Workspace.func_string
is_released has a value which is a Workspace.boolean


=end text

=back



=head2 TypeInfo

=over 4



=item Description

Information about a type

        type_string type_def - resolved type definition id.
        string description - the description of the type from spec-file.
        string spec_def - reconstruction of type definition from spec-file.
        list<spec_version> module_vers - versions of spec-files containing
                given type version.
        list<type_string> type_vers - all versions of type with given type name.
        list<func_string> using_func_defs - list of functions (with versions)
                refering to this type version.
        list<type_string> using_type_defs - list of types (with versions)
                refereing to this type version.
        list<type_string> used_type_defs - list of types (with versions) 
                refered from this type version.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
type_def has a value which is a Workspace.type_string
description has a value which is a string
spec_def has a value which is a string
module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
type_vers has a value which is a reference to a list where each element is a Workspace.type_string
using_func_defs has a value which is a reference to a list where each element is a Workspace.func_string
using_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
type_def has a value which is a Workspace.type_string
description has a value which is a string
spec_def has a value which is a string
module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
type_vers has a value which is a reference to a list where each element is a Workspace.type_string
using_func_defs has a value which is a reference to a list where each element is a Workspace.func_string
using_type_defs has a value which is a reference to a list where each element is a Workspace.type_string
used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string


=end text

=back



=head2 FuncInfo

=over 4



=item Description

Information about function

        func_string func_def - resolved func definition id.
        string description - the description of the function from spec-file.
        string spec_def - reconstruction of function definition from spec-file.
        list<spec_version> module_vers - versions of spec-files containing
                given func version.
        list<func_string> func_vers - all versions of function with given type name.
        list<type_string> used_type_defs - list of types (with versions) 
                refered from this function version.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
func_def has a value which is a Workspace.func_string
description has a value which is a string
spec_def has a value which is a string
module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
func_vers has a value which is a reference to a list where each element is a Workspace.func_string
used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
func_def has a value which is a Workspace.func_string
description has a value which is a string
spec_def has a value which is a string
module_vers has a value which is a reference to a list where each element is a Workspace.spec_version
func_vers has a value which is a reference to a list where each element is a Workspace.func_string
used_type_defs has a value which is a reference to a list where each element is a Workspace.type_string


=end text

=back



=cut

package Bio::KBase::workspace::Client::RpcClient;
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