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
my $primaryArgs = [];
my $servercommand = "list_workspace_objects";
my $translation = {
    "showdeleted"=>"showDeletedObject",
    type => "type",
    workspace => "workspace"
};
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-listobj %o',
    [ 'workspace|w=s', 'ID for workspace', {"default" => workspace()} ],
    [ 'type|t:s','Type required'],
    [ 'showdeleted|s','show all objects that have been deleted', {"default" =>0} ],
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
	print "Cannot list objects!\n";
} else {
    my $tbl = [];
    for (my $i=0; $i < @{$output};$i++) {
        my $r = $output->[$i];
        push(@{$tbl},[$r->[0],$r->[1],$r->[7],$r->[3],$r->[6],$r->[5],$r->[4],$r->[2]]);
    }
	my $table = Text::Table->new(
    'ID', 'Type', 'WS','Vers','Owner','Last modby','Cmd','Moddate'
    );
    $table->load(@$tbl);
    print $table;
}
