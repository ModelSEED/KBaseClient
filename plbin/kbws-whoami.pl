#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::AuthToken;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
my $auth = auth();
if (!defined($auth)) {
	print "Logged in as:\npublic\n";
} else {
	if (auth() =~ m/^(\w+)\t(\S+)$/) {
		print "Logged in as:\n".$1."\n";  
	} else {
		my $token = Bio::KBase::AuthToken->new(token => auth());
		if (!defined($token->user_id())) {
			print "Previous token expired or invalid. Now logged in as:\npublic\n";
			unlink $ENV{HOME}."/.kbase_auth";
		} else {
			print "Logged in as:\n".$token->user_id()."\n";
		}
	}
}
