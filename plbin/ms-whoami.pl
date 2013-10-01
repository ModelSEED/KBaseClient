#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use ModelSEED::Client::MSSeedSupport;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
my $auth = auth();
if (!defined($auth)) {
	print "Logged in as:\npublic\n";
} else {
	my $svr = ModelSEED::Client::MSSeedSupport->new();
	my $login = $svr->kblogin_from_token({
		authtoken => $auth
	});
	if (!defined($login)) {
		print "Previous token expired or invalid. Now logged in as:\npublic\n";
		unlink $ENV{HOME}."/.kbase_auth";
	} else {
		print "Logged in as:\n".$login."\n";
	}
}
