package Bio::KBase::workspaceService::Helpers;
use strict;
use warnings;
use Bio::KBase::workspaceService::Client;
use Exporter;
use parent qw(Exporter);
our @EXPORT_OK = qw( auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta printWorkspaceMeta);
our $defaultURL = "http://kbase.us/services/workspace/";

sub get_ws_client {
    return Bio::KBase::workspaceService::Client->new(workspaceURL());
}

sub auth {
    my $token = shift;
    if ( defined $token ) {
        if (defined($ENV{KB_NO_FILE_ENVIRONMENT})) {
        	$ENV{KB_AUTH_TOKEN} = $token;
        } else {
        	my $filename = "$ENV{HOME}/.kbase_auth";
        	open(my $fh, ">", $filename) || return;
        	print $fh $token;
        	close($fh);
        }
    } else {
    	my $filename = "$ENV{HOME}/.kbase_auth";
    	if (defined($ENV{KB_NO_FILE_ENVIRONMENT}) && defined($ENV{KB_AUTH_TOKEN})) {
        	$token = $ENV{KB_AUTH_TOKEN};
        } elsif ( -e $filename ) {
        	open(my $fh, "<", $filename) || return;
        	$token = <$fh>;
        	chomp($token);
        	close($fh);
        }
    }
    return $token;
}

sub workspace {
    my $set = shift;
    my $workspace;
    my $filename = "$ENV{HOME}/.kbase_workspace";
    if ( defined $set ) {
        open(my $fh, ">", $filename) || return;
        print $fh $set;
        close($fh);
        $workspace = $set;
    } elsif( -e $filename ) {
        open(my $fh, "<", $filename) || return;
        $workspace = <$fh>;
        chomp $workspace;
        close($fh);
    }
    return $workspace;
}

sub workspaceURL {
    my $set = shift;
    my $url;
    my $filename = "$ENV{HOME}/.kbase_workspaceURL";
    if ( defined $set ) {
        if ($set eq "default") {
        	$set = $defaultURL;
        }
        open(my $fh, ">", $filename) || return;
        print $fh $set;
        close($fh);
        $url = $set;
    } elsif( -e $filename ) {
        open(my $fh, "<", $filename) || return;
        $url = <$fh>;
        chomp $url;
        close($fh);
    } else {
        $url = $defaultURL;	
    }
    return $url;
}

sub parseObjectMeta {
    my $object = shift;
    my $hash = {
    	id => $object->[0],
    	type => $object->[1],
    	moddate => $object->[2],
    	instance => $object->[3],
    	command => $object->[4],
    	lastmodifier => $object->[5],
    	owner => $object->[6],
    	workspace => $object->[7],
    	reference => $object->[8],
    };
    return $hash;
}

sub printObjectMeta {
	my $meta = shift;
    my $obj = parseObjectMeta($meta);
    print "Object ID: ".$obj->{id}."\n";
    print "Type: ".$obj->{type}."\n";
    print "Workspace: ".$obj->{workspace}."\n";
    print "Owner: ".$obj->{owner}."\n";
    print "Instance: ".$obj->{instance}."\n";
    print "Moddate: ".$obj->{moddate}."\n";
    print "Last cmd: ".$obj->{command}."\n";
    print "Modified by: ".$obj->{lastmodifier}."\n";
    print "Perm ref: ".$obj->{reference}."\n";
}

sub parseWorkspaceMeta {
    my $object = shift;
    my $hash = {
    	id => $object->[0],
    	owner => $object->[1],
    	moddate => $object->[2],
    	objects => $object->[3],
    	user_permission => $object->[4],
    	global_permission => $object->[5],
    };
    return $hash;
}

sub printWorkspaceMeta {
	my $meta = shift;
    my $obj = parseWorkspaceMeta($meta);
    print "Workspace ID: ".$obj->{id}."\n";
    print "Owner: ".$obj->{owner}."\n";
    print "Moddate: ".$obj->{moddate}."\n";
    print "Objects: ".$obj->{objects}."\n";
    print "User permission: ".$obj->{user_permission}."\n";
    print "Global permission:".$obj->{global_permission}."\n";
}

1;