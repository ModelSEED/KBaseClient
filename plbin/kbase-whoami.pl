#!/usr/bin/env perl
########################################################################
# Simple script based on the kbase-login.pl template for looking up token
# and user name of the logged in user using the Bio::KBase::Auth* libraries.
# Michael Sneddon, mwsneddon@lbl.gov
########################################################################                                                                                                                                     
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::Auth;
use Term::ReadKey;

my $primaryArgs = [];
#Defining usage and options
my ($opt, $usage) = describe_options(
    "$0 <".join("> <",@{$primaryArgs})."> %o\nDetermine who you are logged in as.",
    [ 'token|t', 'Print out user token instead of your user name.' ],
    [ 'help|h|?', 'Print this usage information' ],
    );
if (defined($opt->{help})) {
	print $usage;
	exit;
}
if (defined($ARGV[0])) {
	print $usage;
	exit();
}

my $configs = Bio::KBase::Auth::GetConfigs();
if ($configs->{user_id} && $configs->{token}) {
	if (defined($opt->{token})) {
		print $configs->{token}."\n";
	} else {
		print "You are logged in as:\n".$configs->{user_id}."\n";
	}
} else {
	print "You are not logged in.\n";
}

exit 0;
