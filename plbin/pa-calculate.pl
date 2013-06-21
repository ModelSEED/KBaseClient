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
      pa-calculate -- generate reaction probabilities from a probabilistic annotation

SYNOPSIS
      pa-calculate <ProbAnno ID> <RxnProbs ID> [OPTIONS]

DESCRIPTION
      Generate reaction probabilities from a probabilistic annotation.
      
      Options:
      -d, --debug           Keep intermediate files for debug purposes
      -e, --showerror       Show any errors in execution
      -h, --help            Display this help message, ignore all arguments
      -o, --overwrite       Overwrite existing RxnProbs object with same name
      --probannows          ID of workspace where ProbAnno object is stored
      -t, --templateid      ID of ModelTemplate object
      -m, --templatews      ID of workspace where ModelTemplate object is stored
      -v, --verbose         Print verbose messages
      -w, --rxnprobsws      ID of workspace where RxnProbs object is saved

EXAMPLES
      Annotate:
      > pa-calculate kb\|g.0 kb\|g.0
      
AUTHORS
      Matt Benedict, Mike Mundy
";

# Define usage and options.
my $primaryArgs = [ "ProbAnno ID", "RxnProbs ID" ];
my ( $opt, $usage ) = describe_options(
    'pa-calculate <' . join( "> <", @{$primaryArgs} ) . '> %o',
    [ 'probannows|w=s', 'ID of workspace where ProbAnno object is stored', { "default" => workspace() } ],
    [ 'rxnprobsws|w=s', 'ID of workspace where RxnProbs object is saved', { 'default' => workspace() } ],
    [ 'templateid|t=s', "ID of ModelTemplate object", { "default" => undef } ],
    [ 'templatews|m=s', "ID of workspace where ModelTemplate object is stored", { "default" => undef } ],
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
    "ProbAnno ID" => "probanno",
    "RxnProbs ID" => "rxnprobs",
    rxnprobsws    => "rxnprobs_workspace",
    probannows    => "probanno_workspace",
    debug         => "debug",
    verbose       => "verbose",
    templateid    => "template_model",
    templatews    => "template_model_workspace"
};

# Instantiate parameters for function.
my $params = { auth => auth(), };
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
	print "Reaction probabilities successfully generated in workspace:";
	printObjectMeta($output)
}
exit 0;
