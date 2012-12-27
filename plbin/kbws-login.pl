#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::AuthToken;
use Term::ReadKey;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
#Defining globals describing behavior
my $primaryArgs = ["Username"];
#Defining usage and options
my ($opt, $usage) = describe_options(
    'kbws-login <'.join("> <",@{$primaryArgs}).'> %o',
    [ 'password|p:s', 'User password' ],
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
my $pswd;
if (defined($opt->{password})) {
	$pswd = $opt->{password};
} else {
	$pswd = get_pass();
}
my $token = Bio::KBase::AuthToken->new(user_id => $ARGV[0], password => $pswd);
if (!defined($token->token())) {
	print "Login failed. Now logged in as:\npublic\n";
	unlink $ENV{HOME}."/.kbase_auth";
} else {
	auth($token->token());
	print "Login successful. Now logged in as:\n".$ARGV[0]."\n";
}

sub get_pass {
    my $key  = 0;
    my $pass = ""; 
    print "Password: ";
    ReadMode(4);
    while ( ord($key = ReadKey(0)) != 10 ) {
        # While Enter has not been pressed
        if (ord($key) == 127 || ord($key) == 8) {
            chop $pass;
            print "\b \b";
        } elsif (ord($key) < 32) {
            # Do nothing with control chars
        } else {
            $pass .= $key;
            print "*";
        }
    }
    ReadMode(0);
    print "\n";
    return $pass;
}