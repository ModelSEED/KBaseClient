#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Text::Table;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta);
$|=1;
my $serv = get_ws_client();
#Defining globals describing behavior
my $primaryArgs = ["Job IDs (; delimiter or filename)"];
my $servercommand = "set_job_status";
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-resetjob <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'status|s:s', 'New status to assign to job', {"default" => "queued"} ],
    [ 'delete|d', 'Delete job', {"default" => 0} ],
    [ 'showerror|e', 'Set as 1 to show any errors in execution',{"default"=>0}],
    [ 'help|h|?', 'Print this usage information' ]
);
if (defined($opt->{help})) {
	print $usage;
    exit;
}
#Processing primary arguments
foreach my $arg (@{$primaryArgs}) {
	$opt->{$arg} = shift @ARGV;
	if (!defined($opt->{$arg})) {
		print $usage;
    	exit;
	}
}
#Checking if input ID is actually a filename
my $ids = [split(/;/,$opt->{$primaryArgs->[0]})];
if ($ids->[0] !~ m/^job\.\d+$/ && -e $ids->[0]) {
	open (my $file, "<", $ids->[0]) || die "Couldn't open ".$ids->[0]."!";
	print $ids->[0]."\n";
	$ids = []; 
	while (my $line = <$file>) {
		print $line."\n";
		chomp($line);
		push(@{$ids},$line);
	}
	close($file);
}
#Retrieving current job status
my $jobs;
if ($opt->{showerror} == 0){
    eval {
        $jobs = $serv->get_jobs({
			auth => auth(),
			jobids => $ids
		});
    };
}else{
    $jobs = $serv->get_jobs({
			auth => auth(),
			jobids => $ids
		});
}
if (!defined($jobs)) {
	print "Failed to retrieve specified jobs!\n";
}
my $status = $opt->{status};
if (defined($opt->{"delete"}) && $opt->{"delete"} == 1) {
	$status = "delete";
}
for (my $i=0; $i < @{$jobs};$i++) {
	#Calling the server
	my $output = undef;
	if ($opt->{showerror} == 0) {
	    eval {
	        $output = $serv->set_job_status({
	        	jobid => $jobs->[$i]->{id},
	        	status => $status,
	        	auth => auth(),
	        	currentStatus => $jobs->[$i]->{status}
	        });
	    };
	} else {
	    $output = $serv->set_job_status({
        	jobid => $jobs->[$i]->{id},
        	status => $status,
        	auth => auth(),
        	currentStatus => $jobs->[$i]->{status}
        });
	}
	#Checking output and report results
	if (!defined($output)) {
		print "Could not reset job status!\n";
	} else {
	    print "Job status reset to ".$status." for job ".$jobs->[$i]->{id}."\n";
	}	
}