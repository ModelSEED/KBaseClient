#!/usr/bin/env perl

# Need a license here

use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::probabilistic_annotation::Client;
use Bio::KBase::probabilistic_annotation::Helpers qw(get_probanno_client);
use Bio::KBase::workspaceService::Helpers qw(auth workspace printObjectMeta);

my $manpage =
"
NAME
      pa-annotate -- generate probabilistic annotation for a genome

SYNOPSIS
      pa-annotate <Genome ID> <ProbAnno ID> [OPTIONS]

DESCRIPTION
      Submit a job to generate a probabilistic annotation for a genome. 
      
      Options:
      -d, --debug        Keep intermediate files for debug purposes
      -e, --showerror    Show any errors in execution
      --genomews         ID of workspace where Genome object is stored
      -h, --help         Display this help message, ignore all arguments
      -o, --overwrite    Overwrite existing ProbAnno object with same name
      -v, --verbose      Print verbose messages
      -w, --probannows   ID of workspace where ProbAnno object is saved

EXAMPLES
      Annotate:
      > pa-annotate kb\|g.0 kb\|g.0
      
AUTHORS
      Matt Benedict, Mike Mundy
";

# Define usage and options.
my $primaryArgs = [ "Genome ID", "ProbAnno ID" ];
my ( $opt, $usage ) = describe_options(
    'pa-annotate <' . join( "> <", @{$primaryArgs} ) . '> %o',
    [ 'probannows|w=s', 'ID of workspace where ProbAnno object is saved', { "default" => workspace() } ],
    [ 'genomews=s', 'ID of workspace where Genome object is stored', { "default" => "KBaseCDMGenomes" } ],
    [ 'overwrite|o:i', "Overwrite existing ProbAnno object with same name", { "default" => 0 } ],
    [ 'debug|d:i', "Keep intermediate files for debug purposes", { "default" => 0 } ],
    [ 'showerror|e:i', 'Show any errors in execution', { "default" => 0 } ],
    [ 'verbose|v:i', 'Print verbose messages', { "default" => 0 } ],
    [ 'help|h', 'Show help text' ],
    [ 'usage|?', 'Show usage information' ]
    );
if ( defined( $opt->{help} ) ) {
    print $manpage;
    exit 0;
}
if (defined($opt->{usage})) {
	print $usage;
	exit 0;
}

# Process primary arguments.
foreach my $arg ( @{$primaryArgs} ) {
    $opt->{$arg} = shift @ARGV;
    if ( !defined( $opt->{$arg} ) ) {
		print STDERR "Required arguments are missing\n".$usage;
		exit 1;
    }
}

# Create a client object.
my $client = get_probanno_client();

# Define translation from options to function parameters.
my $translation = {
    "Genome ID"   => "genome",
    "ProbAnno ID" => "probanno",
    genomews      => "genome_workspace",
    probannows    => "probanno_workspace",
    overwrite     => "overwrite",
    debug         => "debug"
};

# Instantiate parameters for function.
my $params = { auth => auth(), };
foreach my $key ( keys( %{$translation} ) ) {
    if ( defined( $opt->{$key} ) ) {
		$params->{ $translation->{$key} } = $opt->{$key};
    }
}

# Call the function.
my $output = $client->annotate($params);
if (!defined($output)) {
	print "Probabilistic annotation failed!\n";
	exit 1;
} else {
	my $jobid;
#	if (ref($output) eq "ARRAY") {
#		$jobid = $output[0];
#	} else {
		$jobid = $output;
#	}
	print "Probabilistic annotation job ".$jobid." successfully submitted\n";
}
exit 0;
