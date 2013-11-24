#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspaceService::Helpers qw(printJobData auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::Helpers qw(get_fba_client runFBACommand universalFBAScriptCode );
use Bio::ModelSEED::MSSeedSupportServer::Client;
#Defining globals describing behavior
my $primaryArgs = ["Filename","Name","SEED login","SEED password"];
my $servercommand = "create_plantseed_job";
my $script = "ms-create-plantseed-genome";
my $translation = {};
#Defining usage and options
my $specs = [
    [ 'transcripts|t', 'FASTA contains trascripts instead of full contigs' ],
    [ 'workspace|w=s', 'Workspace to save FBA results', { "default" => workspace() } ]
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);
$params->{proteins} = 1;
if (defined($opt->{transcripts}) && $opt->{transcripts} == 1) {
	$params->{proteins} = 0;
}
$params->{fasta} = "";
if (!-e $opt->{"Filename"}) {
	print "Could not find input fasta file!\n";
	exit();
}
open(my $fh, "<", $opt->{"Filename"}) || return;
while (my $line = <$fh>) {
	$params->{fasta} .= $line;
}
close($fh);
#Calling the server
my $serv = Bio::ModelSEED::MSSeedSupportServer::Client->new("http://bio-data-1.mcs.anl.gov/services/ms_fba");
my $output = $serv->create_plantseed_job({
	fasta => $params->{fasta},
	proteins => $params->{proteins},
	name => $opt->{"Name"},
	username => $opt->{"SEED login"},
	password => $opt->{"SEED password"}
});
#Checking output and report results
if (!defined($output)) {
	print "Creation of PlantSEED job failed!\n";
} else {
	print "PlantSEED job successfully created:\n";
	printJobData($output);
}
