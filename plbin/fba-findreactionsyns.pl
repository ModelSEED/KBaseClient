#!/usr/bin/env perl
########################################################################
# Authors: Mike Mundy, Matt Benedict, Nick Chia
# Contact email: mundy.michael@mayo.edu
# Development location: Mayo Clinic
########################################################################

use strict;
use warnings;
use Bio::KBase::fbaModelServices::Helpers qw(fbaws get_fba_client runFBACommand universalFBAScriptCode );

#Defining globals describing behavior
my $primaryArgs = [ "Reaction synonyms ID" ];
my $servercommand = "find_reaction_synonyms";
my $script = "fba-findreactionsyns";
my $translation = {
	"Reaction synonyms ID" => "reaction_synonyms",
	workspace => "workspace",
	biochem   => "biochemistry",
	biochemws => "biochemistry_workspace",
};

#Defining usage and options
my $specs = [
	[ 'workspace|w:s', 'ID of workspace for storing reaction synonyms object', { "default" => fbaws() } ],
	[ 'biochem|b:s', 'ID of the biochemistry database', { "default" => "default" } ],
	[ 'biochemws:s', 'ID of workspace containing biochemistry database', { "default" => "kbase" } ],
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);

#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);

#Checking output and report results
if (!defined($output)) {
	print "Find reaction synonyms failed!\n";
} else {
	print "Reaction synonyms successfully generated in workspace:\n";
	printObjectMeta($output);
}