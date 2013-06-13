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
my $primaryArgs = ["Object type","Object ID"];
my $servercommand = "has_object";
my $translation = {
	"Object ID" => "id",
	"Object type" => "type",
    instance => "instance",
    workspace => "workspace"
};
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-exists <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'workspace|w:s', 'ID for workspace', {"default" => workspace()} ],
    [ 'instance|i:i', 'Instance ID' ],
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
foreach my $key (keys(%{$translation})) {
	if (defined($opt->{$key})) {
		$params->{$translation->{$key}} = $opt->{$key};
	}
}
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
	print "Could not determine status of object!\n";
} else {
	if ($output == 1) {
        print $opt->{workspace}."/".$opt->{"Object type"}."/".$opt->{"Object ID"}." exists!\n";
    } else {
        print $opt->{workspace}."/".$opt->{"Object type"}."/".$opt->{"Object ID"}." does not exist!\n";
    }
}
