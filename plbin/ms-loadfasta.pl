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
my $primaryArgs = ["Filename","Name","Username","Password"];
my $servercommand = "create_plantseed_job";
my $script = "ms-loadfasta";
my $translation = {
	proteins => "proteins",
	Name => "name",
	Username => "username",
	Password => "password"
};

#Defining usage and options
my $specs = [
    [ 'proteins|p', 'FASTA contains proteins instead of full contigs' ]
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);
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
my $svr = Bio::ModelSEED::MSSeedSupportServer::Client->new("http://bio-data-1.mcs.anl.gov/services/ms_fba");
my $plantseedGenome = $svr->$servercommand($params);
print "Genome ID: ".$plantseedGenome."\n";