#!/usr/bin/env perl
########################################################################
# Authors: Christopher Henry, Scott Devoid, Paul Frybarger
# Contact email: chenry@mcs.anl.gov
# Development location: Mathematics and Computer Science Division, Argonne National Lab
########################################################################
use strict;
use warnings;
use Bio::KBase::workspace::ScriptHelpers qw(printObjectInfo get_ws_client workspace workspaceURL parseObjectMeta parseWorkspaceMeta printObjectMeta);
use Bio::KBase::fbaModelServices::ScriptHelpers qw(load_table fbaws get_fba_client runFBACommand universalFBAScriptCode );
#Defining globals describing behavior
my $primaryArgs = ["Model"];
my $servercommand = "runfba";
my $script = "fba-runfba";
my $translation = {
	Model => "model",
	modelws => "model_workspace",
	fva => "fva",
	simko => "simulateko",
	minfluxes => "minimizeflux",
	findminmedia => "findminmedia",
	notes => "notes",
	fbaid => "fba",
	workspace => "workspace",
	addtomodel => "add_to_model",
	auth => "auth",
	overwrite => "overwrite",
	expseries => "expseries",
	expseriesws => "expseriesws",
	expsample => "expsample",
	booleanexp => "booleanexp",
	kappa => "kappa",
	omega => "omega",
	solver => "solver",
	biomass => "biomass",
	expthreshold => "expression_threshold_percentile", 
	scalebyflux => "scale_penalty_by_flux"
};
my $fbaTranslation = {
	media => "media",
	mediaws => "media_workspace",
	objfraction => "objfraction",
	allrev => "allreversible",
	maximize => "maximizeObjective",
	defaultmaxflux => "defaultmaxflux",
	defaultminuptake => "defaultminuptake",
	defaultmaxuptake => "defaultmaxuptake",
	simplethermo => "simplethermoconst",
#	thermoconst => "thermoconst",
#	nothermoerror => "nothermoerror",
#	minthermoerror => "minthermoerror",
	addlcpd => "additionalcpds",
	promconstraint => "promconstraint",
	promconstraintws => "promconstraint_workspace",
	efluxsm => "eflux_sample",
	efluxsr => "eflux_series",
	efluxws => "eflux_workspace",
	tintlesample => "tintle_sample",
	tintlews => "tintle_workspace",
	omega => "omega",
	modelws => "model_workspace",
	regulome => "regulome",
	regulomews => "regulome_workspace"
};
#Defining usage and options
my $specs = [
    [ 'fbaid:s', 'ID for FBA in workspace' ],
    [ 'media|m:s', 'Media formulation for FBA' ],
    [ 'mediaws:s', 'Workspace with media formulation' ],
    [ 'modelws:s', 'Workspace with model' ],
    [ 'addlcpd|c:s@', 'Additional compounds (; delimiter)' ],
    [ 'maximize:s', 'Maximize objective', { "default" => 1 } ],
    [ 'biomass|b:s', 'Target biomass (bio1 is default)' ],
    [ 'objterms:s@', 'Objective terms' ],
    [ 'geneko:s@', 'List of gene KO (; delimiter)' ],
    [ 'rxnko:s@', 'List of reaction KO (; delimiter)' ],
    [ 'bounds:s@', 'Custom bounds' ],
    [ 'constraints:s@', 'Custom constraints' ],
    [ 'booleanexp:s', 'Constrain modeling with on/off expression data of specified type. Either "absolute" or "probability"'],
    [ 'expthreshold:s', 'Set threshold percentile for considering genes on or off from expression' ],
    [ 'scalebyflux', 'Scale expression penalties by flux' ],
    [ 'expseries:s', 'ID of expression series' ],
    [ 'expseriesws:s', 'Workspace with expression series' ],
    [ 'expsample:s', 'ID of expression sample in series' ],
    [ 'promconstraint|p:s', 'ID of PromConstraint' ],
    [ 'promconstraintws:s', 'Workspace with PromConstraint' ],
    [ 'regulome:s', 'ID of regulome' ],
    [ 'regulomews:s', 'Workspace with regulome' ],
    [ 'efluxsm:s', 'ID of ExpressionSample for E-Flux analysis' ],
    [ 'efluxsr:s', 'ID of ExpressionSeries for Improved E-Flux analysis (without this but with --efluxsm, the original E-Flux will be conducted.)' ],
    [ 'efluxws:s', 'Workspace with ExpressionSample/Series' ],
    [ 'tintlesample:s', 'ID of ProbabilitySample for Tintle2014 analysis' ],
    [ 'tintlews:s', 'Workspace with ProbabilitySample/Series' ],
    [ 'omega:s', 'Weights of biomass against gene penalty. In (0,1]', { "default" => 0.5}],
    [ 'kappa:s', 'Tolerance to classify genes as unknown, not on or off. In [0,0.5]', {"default" => 0.1}],
    [ 'defaultmaxflux:s', 'Default maximum reaction flux' ],
    [ 'defaultminuptake:s', 'Default minimum nutrient uptake' ],
    [ 'defaultmaxuptake:s', 'Default maximum nutrient uptake' ],
    [ 'uptakelim:s@', 'Atom uptake limits' ],
    [ 'simplethermo', 'Use simple thermodynamic constraints' ],
#    [ 'thermoconst', 'Use full thermodynamic constraints' ],
#    [ 'nothermoerror', 'No uncertainty in thermodynamic constraints' ],
#    [ 'minthermoerror', 'Minimize uncertainty in thermodynamic constraints' ],
    [ 'allrev', 'Treat all reactions as reversible', { "default" => 0 } ],
    [ 'objfraction:s', 'Fraction of objective for follow on analysis', { "default" => 1 }],
    [ 'fva', 'Run flux variability analysis' ],
    [ 'simko', 'Simulate single gene KO' ],
    [ 'minfluxes', 'Minimize fluxes from FBA' ],
    [ 'findminmedia', 'Find minimal media' ],
    [ 'addtomodel', 'Add FBA to model' ],
    [ 'notes:s', 'Notes for flux balance analysis' ],
    [ 'solver:s', 'Solver to use for FBA' ],
    [ 'workspace|w:s', 'Workspace to save FBA results', { "default" => fbaws() } ],
];
my ($opt,$params) = universalFBAScriptCode($specs,$script,$primaryArgs,$translation);
if (!defined($opt->{mediaws}) && defined($opt->{media})) {
	$opt->{mediaws} = $opt->{workspace};
}

if (-e $params->{expsample}) {
	my $data = load_table($params->{expsample},"\t",0);
	foreach my $row (@{$data->{"data"}}) {
		$params->{exp_raw_data}->{$row->[0]} = $row->[1];
	}
	delete $params->{expsample};
}

$params->{formulation} = {
	geneko => [],
	rxnko => [],
	bounds => [],
	constraints => [],
	additionalcpds => [],
	uptakelim => {}
};
foreach my $key (keys(%{$fbaTranslation})) {
	if (defined($opt->{$key})) {
		$params->{formulation}->{$fbaTranslation->{$key}} = $opt->{$key};
	}
}
if (defined($opt->{objterms})) {
	foreach my $terms (@{$opt->{objterms}}) {
		my $array = [split(/;/,$terms)];
		foreach my $term (@{$array}) {
			my $termArray = [split(/:/,$term)];
			if (defined($termArray->[2])) {
				push(@{$params->{formulation}->{objectiveTerms}},$termArray);
			}
		}
	}
}
if (defined($opt->{geneko})) {
	foreach my $gene (@{$opt->{geneko}}) {
		push(@{$params->{formulation}->{geneko}},split(/;/,$gene));
	}
}
if (defined($opt->{rxnko})) {
	foreach my $rxn (@{$opt->{rxnko}}) {
		push(@{$params->{formulation}->{rxnko}},split(/;/,$rxn));
	}
}
if (defined($opt->{additionalcpds})) {
	foreach my $cpd (@{$opt->{additionalcpds}}) {
		push(@{$params->{formulation}->{additionalcpds}},split(/;/,$cpd));
	}
}
if (defined($opt->{bounds})) {
	foreach my $terms (@{$opt->{bounds}}) {
		my $array = [split(/;/,$terms)];
		foreach my $term (@{$array}) {
			my $termArray = [split(/:/,$term)];
			if (defined($termArray->[3])) {
				push(@{$params->{formulation}->{bounds}},$termArray);
			}
		}
	}
}
if (defined($opt->{constraints})) {
	my $count = 0;
	foreach my $constraint (@{$opt->{constraints}}) {
		my $array = [split(/;/,$constraint)];
		my $rhs = shift(@{$array});
		my $sign = shift(@{$array});
		my $terms = [];
		foreach my $term (@{$array}) {
			my $termArray = [split(/:/,$term)];
			if (defined($termArray->[2])) {
				push(@{$terms},$termArray)
			}
		}
		push(@{$params->{formulation}->{constraints}},[$rhs,$sign,$terms,"Constraint ".$count]);
		$count++;
	}
}
if (defined($opt->{uptakelim})) {
	foreach my $uplims (@{$opt->{rxnko}}) {
		my $array = [split(/;/,$uplims)];
		foreach my $uplim (@{$array}) {
			my $pair = [split(/:/,$uplim)];
			if (defined($pair->[1])) {
				$params->{formulation}->{uptakelim}->{$pair->[0]} = $pair->[1];
			}
		}
	}
}
#Calling the server
my $output = runFBACommand($params,$servercommand,$opt);
#Checking output and report results
if (!defined($output)) {
	print "Flux balance analysis failed!\n";
} else {
	print "Flux balance analysis successful:\n";
	printObjectInfo($output);
}
