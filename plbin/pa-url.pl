#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long::Descriptive;

use Bio::KBase::probabilistic_annotation::Helpers qw(get_probanno_url);

my $manpage =
"
NAME
      pa-url -- update or view url of the probabilistic annotation service endpoint

SYNOPSIS
      pa-url [OPTIONS] [NEW_URL]

DESCRIPTION
      Display or set the URL endpoint for the probabilistic annotation service.
      If run with no arguments or options, then the current URL is displayed.
      If run with a single argument, the current URL will be switched to the
      specified URL.  If the specified URL is named default, then the URL is
      reset to the default production URL.
      
      Options:
      -h, --help         display this help message, ignore all arguments

EXAMPLES
      Display the current URL:
      > pa-url
      Current URL is:
      http://kbase.us/services/probabilistic annotation
      
      Use a new URL:
      > pa-url http://localhost:7073
      Current URL is:
      http://localhost:7073
      
      Reset to the default URL:
      > pa-url default
      Current URL is:
      http://kbase.us/services/probabilistic annotation
      
AUTHORS
      Matt Benedict, Mike Mundy
";

#Define usage and options.
my $primaryArgs = ["New server URL"];
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

# Display or update the URL endpoint.
print "Current URL is:\n".get_probanno_url($ARGV[0])."\n";
exit 0;
