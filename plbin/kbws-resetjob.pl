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

my $serv = get_ws_client();
#Defining globals describing behavior
my $primaryArgs = ["Job ID"];
my $servercommand = "set_job_status";
my $translation = {
	"Job ID" => "jobid", 
	status => "status",
};
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
#Instantiating parameters
my $params = {
	auth => auth(),
};
#Retrieving current job status
my $output;
if ($opt->{showerror} == 0){
    eval {
        $output = $serv->get_jobs($params);
    };
}else{
    $output = $serv->get_jobs($params);
}
if (!defined($output)) {
	print "Could not reset job status!\n";
}
foreach my $key (keys(%{$translation})) {
	if (defined($opt->{$key})) {
		$params->{$translation->{$key}} = $opt->{$key};
	}
}
if (defined($opt->{"delete"}) && $opt->{"delete"} == 1) {
	$params->{status} = "delete";
}
for (my $i=0; $i < @{$output};$i++) {
	if ($output->[$i]->{id} eq $params->{jobid}) {
		$params->{currentStatus} = $output->[$i]->{status};
		print $params->{currentStatus}."\n";
		last;
	}
}
#Calling the server
$output = undef;
if ($opt->{showerror} == 0){
    eval {
        $output = $serv->$servercommand($params);
    };
}else{
    $output = $serv->$servercommand($params);
}

#Checking output and report results
if (!defined($output)) {
	print "Could not reset job status!\n";
} else {
    print "Job status reset to:\n".$params->{status}."\n";
}
