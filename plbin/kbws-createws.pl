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
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printWorkspaceMeta);

my $serv = get_ws_client();
#Defining globals describing behavior
my $primaryArgs = ["Workspace ID","Default permissions"];
my $servercommand = "create_workspace";
my $translation = {
	"Workspace ID" => "workspace",
	"Default permissions" => "default_permission",
	auth => "auth"
};
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kb_createws <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'showerror|e', 'Show any errors in execution',{"default"=>0}],
    [ 'verbose|v', 'Print verbose messages' ],
    [ 'help|h|?', 'Print this usage information' ],
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
	print "Workspace creation failed!\n";
} else {
	my $obj = parseWorkspaceMeta($output);
	print "Workspace created with name:\n".$obj->{id}."\n";
}