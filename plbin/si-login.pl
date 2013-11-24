#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
#Defining globals describing behavior
my $primaryArgs = ["Username"];
#Defining usage and options
my ($opt, $usage) = describe_options(
    'si-login <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'help|h|?', 'Print this usage information' ],
);
if (defined($opt->{help})) {
	print $usage;
    exit;
}
if (!defined($ARGV[0])) {
	print $usage;
	exit();
}

if ($ARGV[0] !~ m/^[a-zA-Z0-9_]*$/) {
	print "Login failed! Login names must be alphanumeric!";
	unlink $ENV{HOME}."/.kbase_auth";
}
auth($ARGV[0]);
print "Login successful. Now logged in as:\n".$ARGV[0]."\n";