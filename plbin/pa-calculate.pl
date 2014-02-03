#!/usr/bin/env perl

# Need a license here

use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::probabilistic_annotation::Client;
use Bio::KBase::probabilistic_annotation::Helpers qw(get_probanno_client);
use Bio::KBase::workspace::ScriptHelpers qw(workspace);

my $manpage =
"
NAME
      pa-calculate -- calculate reaction likelihoods from a probabilistic annotation

SYNOPSIS
      pa-calculate <ProbAnno ID> <RxnProbs ID> [OPTIONS]

DESCRIPTION
      Calculate reaction likelihoods from a probabilistic annotation generated
      by the pa-annotate command.
      
      The results are saved in a RxnProbs typed object and contain putative
      gene annotations (based on a cutoff from the gene most likely to fulfill
      each role associated with the reaction) and likelihood scores.
      
      The RxnProbs object can be used as input to gapfilling a metabolic model
      using the --probrxn option for the kbfba-gapfill command.  However, if 
      you do this you must make sure that the same template model is used for
      gapfilling and for computing probabilities.  If you want to avoid this
      issue, we recommend using the ProbAnno object instead.
      
      Options:
      -e, --showerror       Show any errors in execution
      -h, --help            Display this help message, ignore all arguments
      -w, --probannows      ID of workspace where ProbAnno object is stored (default is the current workspace)
      -t, --templateid      ID of ModelTemplate object (default is to use all reactions in the biochemistry)
      -m, --templatews      ID of workspace where ModelTemplate object is stored
      -v, --verbose         Print verbose messages
      -r, --rxnprobsws      ID of workspace where RxnProbs object is to be saved (default is the current workspace)

EXAMPLES
      Calculate reaction likelihoods from probabilistic annotation of E. coli
      K12 genome:
      > pa-calculate kb\|g.0.probanno kb\|g.0.rxnprobs
      
SEE ALSO
      pa-annotate
      kbfba-gapfill
      
AUTHORS
      Matt Benedict, Mike Mundy
";

# Define usage and options.
my $primaryArgs = [ "ProbAnno ID", "RxnProbs ID" ];
my ( $opt, $usage ) = describe_options(
    'pa-calculate <' . join( "> <", @{$primaryArgs} ) . '> %o',
    [ 'probannows|w=s', 'ID of workspace where ProbAnno object is stored (default is the current workspace)', { "default" => workspace() } ],
    [ 'rxnprobsws|r=s', 'ID of workspace where RxnProbs object is saved (default is the current workspace)', { 'default' => workspace() } ],
    [ 'templateid|t=s', "ID of ModelTemplate object", { "default" => undef } ],
    [ 'templatews|m=s', "ID of workspace where ModelTemplate object is stored", { "default" => undef } ],
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
    "ProbAnno ID" => "probanno",
    "RxnProbs ID" => "rxnprobs",
    rxnprobsws    => "rxnprobs_workspace",
    probannows    => "probanno_workspace",
    verbose       => "verbose",
    templateid    => "template_model",
    templatews    => "template_model_workspace"
};

# Instantiate parameters for function.
my $params = { };
foreach my $key ( keys( %{$translation} ) ) {
    if ( defined( $opt->{$key} ) ) {
		$params->{ $translation->{$key} } = $opt->{$key};
    }
}

# Call the function.
my $output = $client->calculate($params);
if (!defined($output)) {
	print "Calculating reaction probabilities failed!\n";
	exit 1;
} else {
	print "Reaction probabilities successfully calculated and saved in ".$output->[7]."/".$output->[1]."\n";
}
exit 0;
