#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::probabilistic_annotation::Client;
use Bio::KBase::probabilistic_annotation::Helpers qw(get_probanno_client);
use Bio::KBase::workspaceService::Helpers qw(workspace printObjectMeta);

my $manpage =
"
NAME
      pa-getprobanno -- Get a table of probabilistic annotations

SYNOPSIS
      pa-getprobanno [ProbAnno ID] [Workspace]

DESCRIPTION
      Get a table of annotation probabilities from a ProbAnno object.
      Each gene-annotation pair is given its own row in the table. An annotation is
      a set of roles delimited by '///'.
      
      If -r is specified, gets gene-role pairs instead (the probability of the
      role is computed as the sum of the probabilities of annotations containing it).

      Options:
      -h, --help         display this help message, ignore all arguments
      -r, --roles

EXAMPLES
      > pa-getprobanno 'kb|g.0.probanno'
      gene    annotation   likelihood

      > pa-getprobanno 'kb|g.0.probanno' -r
      gene    role    likelihood

SEE ALSO
      pa-annotate
     
AUTHORS
      Matt Benedict, Mike Mundy
";

#Define usage and options.
my $primaryArgs = ["ProbAnno ID", "Workspace"];
my ($opt, $usage) = describe_options(
    'pa-url <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'help|h', 'Show help text' ],
    [ 'usage|?', 'Show usage information' ],
    [ 'roles|r:i', 'Print role likelihoods instead of annotation likelihoods']
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
    "ProbAnno ID"   => "probanno",
    "Workspace" => "probanno_workspace"
};

# Instantiate parameters for function.
my $params = { };
foreach my $key ( keys( %{$translation} ) ) {
    if ( defined( $opt->{$key} ) ) {
	$params->{ $translation->{$key} } = $opt->{$key};
    }
}

# Call the function.
my $output = $client->get_probanno($params);
if (!defined($output)) {
    print "Getting probanno failed!\n";
    exit 1;
} else {
    my(@titles);
    if ( defined($opt->{roles} )) {
	@titles = ("gene", "role", "likelihood");
    } else {
	@titles = ("gene", "annotation", "likelihood");
    }
    
    print join("\t", @titles);
    print "\n";
    foreach my $gene (keys %$output) {
	my $roleToProb = {};
	foreach my $roleprob (@{$output->{$gene}}) {
	    if ( defined($opt->{roles}) ) {
		# Extract the roles from the roleset string and add them up if there are duplicates.
		my $roles = [];
		@$roles = split(/\/\/\//, $roleprob->[0]);
		foreach my $role (@$roles) {
		    if ( defined($roleToProb->{$role}) ) {
			$roleToProb->{$role} += $roleprob->[1];
		    } else {
			$roleToProb->{$role} = $roleprob->[1];
		    }
		}
	    } else {
		$roleToProb->{$roleprob->[0]} = $roleprob->[1];
	    }
	}
	foreach my $role (keys %$roleToProb) {
	    print $gene."\t".$role."\t".$roleToProb->{$role}."\n";
	}
    }
}
exit 0;


