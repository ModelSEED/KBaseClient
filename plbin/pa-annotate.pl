#!/usr/bin/env perl

# Need a license here

use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::probabilistic_annotation::Client;
use Bio::KBase::probabilistic_annotation::Helpers qw(get_probanno_client);
use Bio::KBase::workspaceService::Helpers qw(workspace printObjectMeta);

my $manpage =
"
NAME
      pa-annotate -- generate probabilistic annotation for a genome

SYNOPSIS
      pa-annotate <Genome ID> <ProbAnno ID> [OPTIONS]

DESCRIPTION
      Generate alternative annotations for every gene in a genome together
      with their likelihoods.  The current method for calculating likelihoods
      is based on similarity (BLAST) to genes in subsystems and genes with
      literature evidence.
      
      This command takes a significant amount of time to run (since it has to
      run BLAST against a large database), so it is placed on a queue and 
      returns a job ID.  Use the pa-checkjob command to see if your job has
      finished.  When it is done the results are saved in a ProbAnno typed
      object with the specified ID.
      
      The ProbAnno object can be used as input to gapfilling a metabolic model
      using the --probanno option for the kbfba-gapfill command.
      
      Options:
      -e, --showerror    Show any errors in execution
      --genomews         ID of workspace where Genome object is stored (default is the current workspace)
      -h, --help         Display this help message, ignore all arguments
      -v, --verbose      Print verbose messages
      -w, --probannows   ID of workspace where ProbAnno object is to be saved (default is the current workspace)

EXAMPLES
      Generate probabilistic annotation for E. coli K12 genome:
      > pa-annotate kb\|g.0.genome kb\|g.0.probanno
      
SEE ALSO
      pa-calculate
      pa-url
      pa-checkjob
      kbfba-gapfill
      
AUTHORS
      Matt Benedict, Mike Mundy
";

# Define usage and options.
my $primaryArgs = [ "Genome ID", "ProbAnno ID" ];
my ( $opt, $usage ) = describe_options(
    'pa-annotate <' . join( "> <", @{$primaryArgs} ) . '> %o',
    [ 'probannows|w=s', 'ID of workspace where ProbAnno object is saved (default is the current workspace)', { "default" => workspace() } ],
    [ 'genomews=s', 'ID of workspace where Genome object is stored (default is the current workspace)', { "default" => workspace() } ],
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
};

# Instantiate parameters for function.
my $params = { };
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
