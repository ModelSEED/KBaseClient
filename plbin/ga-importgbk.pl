#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspace::ScriptHelpers qw( printObjectInfo get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::ScriptHelpers qw(fbaws get_fba_client runFBACommand universalFBAScriptCode );
#Defining globals describing behavior
my $primaryArgs = ["GBK directory"];
my $servercommand = "gbk_to_genome";
my $script = "ga-importgbk";
my $translation = {
	workspace => "workspace",
};
#Defining usage and options
my $specs = [
    [ 'workspace|w=s', 'Workspace to load genome into', { "default" => fbaws() } ],
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);
#Loading GTF file
if (!-d $opt->{"GBK directory"}) {
	print "Cannot find specified genbank directory!\n";
	die;
}
my $list = [glob($opt->{"GBK directory"}."/*")];
my $combined = "";
for (my $i=0; $i < @{$list}; $i++) {
	if ($list->[$i] !~ m/All\.gbk/) {
		open( my $fh, "<", $list->[$i]);
		{
		    local $/;
		    $combined .= <$fh>;
		    $combined .= "\n";
		}
		close($fh);
	}
}
print $combined;