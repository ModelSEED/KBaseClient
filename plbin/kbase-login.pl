#!/usr/bin/env perl
########################################################################
# Modified version of the original kbase-login.pl script in the kbase workspace
# service git module. Adapted to work with updated Bio::KBase::Auth* libraries
# and added into the main auth repo.  Steve Chan sychan@lbl.gov
# 
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################                                                                                                                                     
use strict;
use warnings;
use Getopt::Long::Descriptive;
use Bio::KBase::AuthToken;
use Term::ReadKey;

my $primaryArgs = ["Username"];
#Defining usage and options
my ($opt, $usage) = describe_options(
    "$0 <".join("> <",@{$primaryArgs})."> %o\nAcquire a KBase authentication token for the username specified. " .
    "Prompts for password if not specified on the command line. " . 
    "Upon successful login the token will be placed in the INI format file " .
    $Bio::KBase::Auth::ConfPath .
    " and used by default for KBase clients that require authentication",
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
	# Clear any token that has been set
	Bio::KBase::Auth::SetConfigs( token => undef, user_id => undef);
} else {
        # Set the user_id and token, but clear the password
	Bio::KBase::Auth::SetConfigs( token => $token->token(),
				      user_id => $ARGV[0],
				      password => undef);
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
