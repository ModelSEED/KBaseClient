#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspace::ScriptHelpers qw(printObjectInfo get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::ScriptHelpers qw(fbaws get_fba_client runFBACommand universalFBAScriptCode );

my $manpage =
"
NAME
      ga-add-gene - add gene

DESCRIPTION
      

EXAMPLES
      
SEE ALSO
      

AUTHORS
      Christopher Henry
";

#Defining globals describing behavior
my $primaryArgs = ["Genome","Gene ID"];
my $servercommand = "add_features";
my $script = "ga-add-gene";
my $translation = {
	Genome => "genome",
	genomews => "genome_workspace",
	outputid => "output_id",
	workspace => "workspace",
};
#Defining usage and options
my $specs = [
    [ 'genomews=s', 'Workspace where genome is located' ],
    [ 'outputid=s', 'ID to which genome should be saved'],
    [ 'function=s', 'Function of the gene'],
    [ 'type=s', 'Type of the gene'],
    [ 'proteinseq=s', 'Type of the gene'],
    [ 'dnaseq=s', 'Type of the gene'],
    [ 'locations=s', 'List of locations for gene on contigs (contig/start/stop/direction)'],
    [ 'aliases=s', 'List of aliases for gene (; delimited)'],
    [ 'publications=s', 'List of publications for gene (; delimited)'],
    [ 'annotations=s', 'List of notes for gene (; delimited)'],
    [ 'workspace|w=s', 'Reference default workspace', { "default" => fbaws() } ]
];





list<tuple<feature_id feature,string function,string type,list<string> aliases,list<string> publications,list<string> annotations,string protein_translation,string dna_sequence,list<tuple<string,int,string,int>> locations>> genes;


my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation,$manpage);
$params->{features} = [
	$opt->{"Gene ID"},
	undef,
	undef,
	undef,
	undef,
	undef,
	undef,
	undef,
	undef
];
if (defined($opt->{function})) {
	$params->{features}->[1] = $opt->{function};
}
if (defined($opt->{type})) {
	$params->{features}->[2] = $opt->{type};
}
if (defined($opt->{proteinseq})) {
	$params->{features}->[3] = $opt->{proteinseq};
}
if (defined($opt->{dnaseq})) {
	$params->{features}->[4] = $opt->{dnaseq};
}
if (defined($opt->{locations})) {
	my $array = [split(/;/,$opt->{locations})];
	for (my $i=0; $i < @{$array}; $i++) {
		my $subarray = [split(/\//,$array->[$i])];
		push(@{$params->{features}->[5]},[$subarray]);
	}
}
if (defined($opt->{function})) {
	$params->{features}->[6] = $opt->{function};
}
if (defined($opt->{function})) {
	$params->{features}->[7] = $opt->{function};
}
if (defined($opt->{function})) {
	$params->{features}->[8] = $opt->{function};
}
#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);
#Checking output and report results
if (!defined($output)) {
	print "Gene addition failed!\n";
} else {
	print "Gene successfully added:\n";
	printObjectInfo($output);
}
