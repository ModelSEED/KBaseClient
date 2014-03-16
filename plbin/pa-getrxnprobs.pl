#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::probabilistic_annotation::Client;
use Bio::KBase::probabilistic_annotation::Helpers qw(get_probanno_client);

my $manpage =
"
NAME
      pa-getrxnprobs -- Get a table of reaction probabilities from a rxnprobs object

SYNOPSIS
      pa-getrxnprobs [RxnProbs ID] [Workspace]

DESCRIPTION
      Get a table of reaction probabilities from a RxnProbs object.
      Each reaction in the rxnprobs object is given a single row in the output table.
      Reactions with no complexes linked to them will have no rows in the table.
      
      Options:
      -h, --help         display this help message, ignore all arguments

EXAMPLES
      > pa-getrxnprobs 'kb|g.0.rxnprobs' 'MyWorkspace'
      reaction_id   probability   complex_diagnostic   complex_details   putative_GPR

SEE ALSO
      pa-calculate
     
AUTHORS
      Matt Benedict, Mike Mundy
";

#Define usage and options.
my $primaryArgs = ["RxnProbs ID", "Workspace"];
my ($opt, $usage) = describe_options(
    'pa-url <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'help|h', 'Show help text' ],
    [ 'usage|?', 'Show usage information' ],
);
if (defined($opt->{help})) {
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
    "RxnProbs ID"   => "rxnprobs",
    "Workspace" => "rxnprobs_workspace"
};

# Instantiate parameters for function.
my $params = { };
foreach my $key ( keys( %{$translation} ) ) {
    if ( defined( $opt->{$key} ) ) {
	$params->{ $translation->{$key} } = $opt->{$key};
    }
}

# Call the function.
my $output = $client->get_rxnprobs($params);
if (!defined($output)) {
    print "Probabilistic annotation failed!\n";
    exit 1;
} else {
    my @titles = ("reaction_id", "probability", "complex_diagnostic", "complex_details", "putative_GPR");
    
    print join("\t", @titles);
    print "\n";
    foreach my $rxnprob (@$output) {
	print join("\t", (@$rxnprob));
	print "\n";
    }
}
exit 0;


