package Bio::KBase::workspaceService::Helpers;
use strict;
use warnings;
use Bio::KBase::workspaceService::Client;
use Exporter;
use parent qw(Exporter);
our @EXPORT_OK = qw(loadTableFile printJobData auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta printWorkspaceMeta);
our $defaultURL = "http://kbase.us/services/workspace/";

my $CurrentWorkspace;
my $CurrentURL;

sub get_ws_client {
	if (workspaceURL() eq "impl") {
		require "Bio/KBase/workspaceService/Impl.pm";
		return Bio::KBase::workspaceService::Impl->new();
	}
    return Bio::KBase::workspaceService::Client->new(workspaceURL());
}

sub auth {
    my $token = shift;
    if ( defined $token ) {
        if (defined($ENV{KB_RUNNING_IN_IRIS})) {
        	$ENV{KB_AUTH_TOKEN} = $token;
        } else {
        	my $filename = "$ENV{HOME}/.kbase_auth";
        	open(my $fh, ">", $filename) || return;
        	print $fh $token;
        	close($fh);
        }
    } else {
    	my $filename = "$ENV{HOME}/.kbase_auth";
    	if (defined($ENV{KB_RUNNING_IN_IRIS})) {
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
    if (defined($set)) {
    	$CurrentWorkspace = $set;
    	my $auth = auth();
    	if (!defined($auth)) {
    		if (!defined($ENV{KB_RUNNING_IN_IRIS})) {
	    		my $filename = "$ENV{HOME}/.kbase_workspace";
	    		open(my $fh, ">", $filename) || return;
		        print $fh $CurrentWorkspace;
		        close($fh);
    		} else {
    			$ENV{KB_WORKSPACE} = $CurrentWorkspace;
    		}
    	} else {
    		my $client = get_ws_client();
    		$client->set_user_settings({
	    		setting => "workspace",
				value => $set,
				auth => $auth
	    	});
    	}
    } elsif (!defined($CurrentWorkspace)) {
    	my $auth = auth();
    	if (!defined($auth)) {
    		if (!defined($ENV{KB_RUNNING_IN_IRIS})) {
	    		my $filename = "$ENV{HOME}/.kbase_workspace";
	    		if( -e $filename ) {
		    		open(my $fh, "<", $filename) || return;
			        $CurrentWorkspace = <$fh>;
			        chomp $CurrentWorkspace;
			        close($fh);
	    		} else {
	    			$CurrentWorkspace = "default";
	    		}
    		} elsif (defined($ENV{KB_WORKSPACE})) {
	    		$CurrentWorkspace = $ENV{KB_WORKSPACE};
	    	} else {
				$CurrentWorkspace = "default";
    		} 
    	} else {
    		my $client = get_ws_client();
    		my $settings = $client->get_user_settings({
				auth => $auth
	    	});
	    	$CurrentWorkspace = $settings->{workspace};
    	}
    }
    return $CurrentWorkspace;
}

sub workspaceURL {
    my $set = shift;
    if (defined($set)) {
    	if ($set eq "default") {
        	$set = $defaultURL;
        }
    	$CurrentURL = $set;
    	if (!defined($ENV{KB_RUNNING_IN_IRIS})) {
	    	my $filename = "$ENV{HOME}/.kbase_workspaceURL";
	    	open(my $fh, ">", $filename) || return;
		    print $fh $CurrentURL;
		    close($fh);
    	} elsif ($ENV{KB_WORKSPACEURL}) {
    		$ENV{KB_WORKSPACEURL} = $CurrentURL;
    	}
    } elsif (!defined($CurrentURL)) {
    	if (!defined($ENV{KB_RUNNING_IN_IRIS})) {
	    	my $filename = "$ENV{HOME}/.kbase_workspaceURL";
	    	if( -e $filename ) {
		   		open(my $fh, "<", $filename) || return;
		        $CurrentURL = <$fh>;
		        chomp $CurrentURL;
		        close($fh);
	    	} else {
	    		$CurrentURL = $defaultURL;
	    	}
    	} elsif (defined($ENV{KB_WORKSPACEURL})) {
	    	$CurrentURL = $ENV{KB_WORKSPACEURL};
	    } else {
			$CurrentURL = "http://bio-data-1.mcs.anl.gov/services/fba_gapfill";
    		#$CurrentURL = $defaultURL;
    	}
    }
    return $CurrentURL;
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
    	chsum => $object->[9],
    	metadata => $object->[10]
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
    print "Checksum: ".$obj->{chsum}."\n";
    if (defined($obj->{metadata})) {
    	foreach my $key (keys(%{$obj->{metadata}})) {
    		print $key.": ".$obj->{metadata}->{$key}."\n";
    	}
    }
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

sub printJobData {
    my $job = shift;
    print "Job ID: ".$job->{id}."\n";
    print "Job Type: ".$job->{type}."\n";
    print "Job Owner: ".$job->{owner}."\n";
    print "Command: ".$job->{queuecommand}."\n";
    print "Queue time: ".$job->{queuetime}."\n";
    if (defined($job->{starttime})) {
    	print "Start time: ".$job->{starttime}."\n";
    }
    if (defined($job->{completetime})) {
    	print "Complete time: ".$job->{completetime}."\n";
    }
    print "Job Status: ".$job->{status}."\n";
    if (defined($job->{jobdata}->{postprocess_args}->[0]->{model_workspace})) {
    	print "Model: ".$job->{jobdata}->{postprocess_args}->[0]->{model_workspace}."/".$job->{jobdata}->{postprocess_args}->[0]->{model}."\n";
    }
    if (defined($job->{jobdata}->{postprocess_args}->[0]->{formulation}->{formulation}->{media})) {
    	print "Media: ".$job->{jobdata}->{postprocess_args}->[0]->{formulation}->{formulation}->{media}."\n";
    }
    if (defined($job->{jobdata}->{postprocess_args}->[0]->{formulation}->{media})) {
    	print "Media: ".$job->{jobdata}->{postprocess_args}->[0]->{formulation}->{media}."\n";
    }
    if (defined($job->{jobdata}->{qsubid})) {
    	print "Qsub ID: ".$job->{jobdata}->{qsubid}."\n";
    }
    if (defined($job->{jobdata}->{error})) {
    	print "Error: ".$job->{jobdata}->{error}."\n";
    }    
}

sub loadTableFile {
	my ($filename) = @_;
	if (!-e $filename) {
		print "Could not open table file ".$filename."!\n";
		exit();
	}
	open(my $fh, "<", $filename) || return;
	my $headingline = <$fh>;
	my $tbl;
	chomp($headingline);
	my $headings = [split(/\t/,$headingline)];
	for (my $i=0; $i < @{$headings}; $i++) {
		$tbl->{headings}->{$headings->[$i]} = $i;
	}
	while (my $line = <$fh>) {
		chomp($line);
		push(@{$tbl->{data}},[split(/\t/,$line)]);
	}
	close($fh);
	return $tbl;
}

1;