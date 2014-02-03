#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspace::ScriptHelpers qw(get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::ScriptHelpers qw(get_fba_client runFBACommand universalFBAScriptCode );
#Defining globals describing behavior
my $primaryArgs = ["FBAModel ID","Format (html,sbml,json,cytoseed,readable)"];
my $servercommand = "export_fbamodel";
my $script = "fba-exportfbamodel";
my $translation = {
	"Format (html,sbml,json,cytoseed,readable)" => "format",
	"FBAModel ID" => "model",
	workspace => "workspace",
	auth => "auth",
};
#Defining usage and options
my $specs = [
    [ 'workspace|w:s', 'Workspace with model', { "default" => workspace() } ]
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);
#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);
#Checking output and report results
if (!defined($output)) {
	print "FBAModel export failed!\n";
} else {
	print $output;
}