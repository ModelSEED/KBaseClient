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
my $servercommand = "get_jobs";
my $script = "kbws-checkjob";
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-checkjob <Job ID> %o',
    [ 'joberror|j', 'Use flag to print the job error output',{"default"=>0}],
    [ 'qsub|q', 'Use flag to show qsub ID for jobs',{"default"=>0}],
    [ 'showerror|e', 'Use flag to show any errors in execution',{"default"=>0}],
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
	jobids => [$opt->{"Job ID"}]
};
#Calling the server
my $output;
if ($opt->{showerror} == 0){
    eval {
        $output = $serv->$servercommand($params);
    };
}else{
    $output = $serv->$servercommand($params);
}
#Checking output and report results
if (!defined($output)) {
	print "Could not retreive job!\n";
} else {
    my $fbajob;
    my $jobdata;
    if ($opt->{showerror} == 0){
	    eval {
	        $jobdata = $serv->get_object_by_ref({
	        	reference => $output->[0]->{id},
	        	auth => auth()
	        });
	    };
	}else{
	    $jobdata = $serv->get_object_by_ref({
        	reference => $output->[0]->{id},
        	auth => auth()
        });
	}
	if (defined($jobdata)) {
		$fbajob = $jobdata->{data};
	}
    print "Job ID:".$output->[0]->{id}."\n";   
    if (defined($fbajob)) {
    	print "Model:".$fbajob->{postprocess_args}->[0]->{model_workspace}."/".$fbajob->{postprocess_args}->[0]->{model}."\n";
    	print "Command:".$fbajob->{queuing_command}."\n";
    	if (defined($fbajob->{postprocess_args}->[0]->{formulation})) {
    		if (defined($fbajob->{postprocess_args}->[0]->{formulation}->{formulation}->{media})) {
    			print "Media:".$fbajob->{postprocess_args}->[0]->{formulation}->{formulation}->{media}."\n";
    		} elsif (defined($fbajob->{postprocess_args}->[0]->{formulation}->{media})) {
    			print "Media:".$fbajob->{postprocess_args}->[0]->{formulation}->{media}."\n";
    		}
    	}
    	print "Is complete:".$fbajob->{complete}."\n";
    }
    print "Status:".$output->[0]->{status}."\n";
    print "Owner:".$output->[0]->{owner}."\n";
    print "Queued:".$output->[0]->{queuetime}."\n";
    print "Started:".$output->[0]->{starttime}."\n";
    print "Completed:".$output->[0]->{completetime}."\n";
	if ($opt->{qsub} == 1) {
       print "Qsub ID:".$output->[0]->{jobdata}->{qsubid}."\n";
	}
	if ($opt->{joberror} == 1) {
		if (defined($output->[0]->{jobdata}->{error})) {
			print "Error output:\n".$output->[0]->{jobdata}->{error}."\n";
    	} else {
    		print "Error output: none\n";
    	}
	}
}