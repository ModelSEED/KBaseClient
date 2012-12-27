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
my $primaryArgs = ["Object type","Original object ID","New object ID"];
my $servercommand = "copy_object";
my $translation = {
	"New object ID" => "new_id",
	"Original object ID" => "source_id",
    "newworkspace" => "new_workspace",
    "workspace" => "source_workspace",
    "Object type" => "type",
    "instance" => "instance"
};
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-copy <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'newworkspace|n:s', 'ID for new workspace', {"default" => workspace()} ],
    [ 'instance|i=i', 'Instance ID' ],
    [ 'workspace|s:s', 'ID for source workspace', {"default" => workspace()} ],
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
	print "Object could not be copied!\n";
} else {
	print "Object copied to new ID:\n".$opt->{"New object ID"}."\n";
}
