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
use JSON -support_by_pp;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta);

my $serv = get_ws_client();
#Defining globals describing behavior
my $primaryArgs = ["Object type","Object ID"];
my $servercommand = "get_object";
my $translation = {
	"Object ID" => "id",
	"Object type" => "type",
    workspace => "workspace",
    instance => "instance"
};
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-get <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'workspace|w:s', 'ID for workspace', {"default" => workspace()} ],
    [ 'instance|i:i', 'Instance ID' ],
    [ 'pretty|p', 'Pretty print JSON object' ],
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
	print "Object could not be retrieved!\n";
} else {
    if (defined($output->{data})) {
        if (ref($output->{data})) {
            print to_json( $output->{data}, { utf8 => 1, pretty => $opt->{pretty} } )."\n";
        } else {
            print $output->{data}."\n";
        }
    } else {
        print "No data retrieved!\n";
    }
}