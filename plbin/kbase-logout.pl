#!/usr/bin/env perl
########################################################################
# Adapted from original kbws-logout.pl script from kbase workspace module
# Clears the auth_token and user_id fields from the ~/.kbase_config file
# (or whatever file Bio::KBase::Auth determines is the config file path)
# Steve Chan sychan@lbl.gov
#
# original headers follow:
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::Auth;
my $primaryArgs = [];

#Defining usage and options
my ($opt, $usage) = describe_options(
    "$0 %o\nClears any kbase authentication tokens from the INI file " .
    $Bio::KBase::Auth::ConfPath .
    " so that you are logged out. Takes no options, and does not complain if you don't have a token set.",
    [ 'help|h|?', 'Print this usage information' ],
);
if (defined($opt->{help})) {
	print $usage;
    exit;
}

Bio::KBase::Auth::SetConfigs( user_id => undef, token => undef);
print "Logged in as:\npublic\n";

