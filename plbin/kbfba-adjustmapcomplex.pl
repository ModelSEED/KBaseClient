#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspaceService::Helpers qw(auth get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::Helpers qw(get_fba_client runFBACommand universalFBAScriptCode );
#Defining globals describing behavior
my $primaryArgs = ["Map ID","Complex ID"];
my $servercommand = "adjust_mapping_complex";
my $script = "kbfba-adjustmapcomplex";
my $translation = {
	"Map ID" => "map",
	"Complex ID" => "complex",
	workspace => "workspace",
	name => "name",
	"new" => "new",
	"delete" => "delete",
	auth => "auth"
};
#Defining usage and options
my $specs = [
    [ 'name=s', 'Name of complex' ],
    [ 'new', 'Create new complex' ],
    [ 'delete', 'Delete specified complex' ],
    [ 'rolesToAdd=s@', 'Roles to add to complex (role id:triggering:optional:type)' ],
    [ 'rolesToRemove=s@', 'Roles to remove from complex (; delimited)' ],
    [ 'workspace|w=s', 'Workspace to save FBA results', { "default" => workspace() } ],
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);
if (defined($opt->{rolesToAdd})) {
	foreach my $role (@{$opt->{rolesToAdd}}) {
		my $rolelist = [split(/;/,$role)];
		foreach my $roleitem (@{$rolelist}) {
			push(@{$params->{rolesToAdd}},[split(/:/,$roleitem)]);
		}
	}
}
if (defined($opt->{rolesToRemove})) {
	foreach my $role (@{$opt->{rolesToRemove}}) {
		push(@{$params->{rolesToRemove}},split(/;/,$role));
	}
}
#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);
#Checking output and report results
if (!defined($output)) {
	print "Adjustment of map complex failed!\n";
} else {
	print "Adjustment of map complex successful:\n";
}