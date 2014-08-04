package Bio::KBase::GenomeAnnotation::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::GenomeAnnotation::Client

=head1 DESCRIPTION


API Access to the Genome Annotation Service.

Provides support for gene calling, functional annotation, re-annotation. Use to extract annotation in
formation about an existing genome, or to create new annotations.


=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'https://kbase.us/services/genome_annotation';
    }

    my $self = {
	client => Bio::KBase::GenomeAnnotation::Client::RpcClient->new,
	url => $url,
    };

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 genome_ids_to_genomes

  $genomes = $obj->genome_ids_to_genomes($ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$ids is a reference to a list where each element is a genome_id
$genomes is a reference to a list where each element is a genomeTO
genome_id is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$ids is a reference to a list where each element is a genome_id
$genomes is a reference to a list where each element is a genomeTO
genome_id is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Given one or more Central Store genome IDs, convert them into genome objects.

=back

=cut

sub genome_ids_to_genomes
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genome_ids_to_genomes (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genome_ids_to_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genome_ids_to_genomes');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.genome_ids_to_genomes",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genome_ids_to_genomes',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genome_ids_to_genomes",
					    status_line => $self->{client}->status_line,
					    method_name => 'genome_ids_to_genomes',
				       );
    }
}



=head2 create_genome

  $genome = $obj->create_genome($metadata)

=over 4

=item Parameter and return types

=begin html

<pre>
$metadata is a genome_metadata
$genome is a genomeTO
genome_metadata is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
genome_id is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$metadata is a genome_metadata
$genome is a genomeTO
genome_metadata is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
genome_id is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Create a new genome object and assign metadata.

=back

=cut

sub create_genome
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function create_genome (received $n, expecting 1)");
    }
    {
	my($metadata) = @args;

	my @_bad_arguments;
        (ref($metadata) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"metadata\" (value was \"$metadata\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to create_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'create_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.create_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'create_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method create_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'create_genome',
				       );
    }
}



=head2 create_genome_from_SEED

  $genome = $obj->create_genome_from_SEED($genome_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_id is a string
$genome is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_id is a string
$genome is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Create a new genome object based on data from the SEED project.

=back

=cut

sub create_genome_from_SEED
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function create_genome_from_SEED (received $n, expecting 1)");
    }
    {
	my($genome_id) = @args;

	my @_bad_arguments;
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"genome_id\" (value was \"$genome_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to create_genome_from_SEED:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'create_genome_from_SEED');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.create_genome_from_SEED",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'create_genome_from_SEED',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method create_genome_from_SEED",
					    status_line => $self->{client}->status_line,
					    method_name => 'create_genome_from_SEED',
				       );
    }
}



=head2 create_genome_from_RAST

  $genome = $obj->create_genome_from_RAST($genome_or_job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_or_job_id is a string
$genome is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_or_job_id is a string
$genome is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Create a new genome object based on a RAST genome.

=back

=cut

sub create_genome_from_RAST
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function create_genome_from_RAST (received $n, expecting 1)");
    }
    {
	my($genome_or_job_id) = @args;

	my @_bad_arguments;
        (!ref($genome_or_job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"genome_or_job_id\" (value was \"$genome_or_job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to create_genome_from_RAST:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'create_genome_from_RAST');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.create_genome_from_RAST",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'create_genome_from_RAST',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method create_genome_from_RAST",
					    status_line => $self->{client}->status_line,
					    method_name => 'create_genome_from_RAST',
				       );
    }
}



=head2 set_metadata

  $genome_out = $obj->set_metadata($genome_in, $metadata)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$metadata is a genome_metadata
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
genome_metadata is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$metadata is a genome_metadata
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
genome_metadata is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string


=end text

=item Description

Modify genome metadata.

=back

=cut

sub set_metadata
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function set_metadata (received $n, expecting 2)");
    }
    {
	my($genome_in, $metadata) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($metadata) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"metadata\" (value was \"$metadata\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to set_metadata:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'set_metadata');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.set_metadata",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'set_metadata',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method set_metadata",
					    status_line => $self->{client}->status_line,
					    method_name => 'set_metadata',
				       );
    }
}



=head2 add_contigs

  $genome_out = $obj->add_contigs($genome_in, $contigs)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$contigs is a reference to a list where each element is a contig
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$contigs is a reference to a list where each element is a contig
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Add a set of contigs to the genome object.

=back

=cut

sub add_contigs
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function add_contigs (received $n, expecting 2)");
    }
    {
	my($genome_in, $contigs) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($contigs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"contigs\" (value was \"$contigs\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to add_contigs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'add_contigs');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.add_contigs",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'add_contigs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method add_contigs",
					    status_line => $self->{client}->status_line,
					    method_name => 'add_contigs',
				       );
    }
}



=head2 add_contigs_from_handle

  $genome_out = $obj->add_contigs_from_handle($genome_in, $contigs)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$contigs is a reference to a list where each element is a contig
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$contigs is a reference to a list where each element is a contig
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Add a set of contigs to the genome object, loading the contigs
from the given handle service handle.

=back

=cut

sub add_contigs_from_handle
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function add_contigs_from_handle (received $n, expecting 2)");
    }
    {
	my($genome_in, $contigs) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($contigs) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"contigs\" (value was \"$contigs\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to add_contigs_from_handle:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'add_contigs_from_handle');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.add_contigs_from_handle",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'add_contigs_from_handle',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method add_contigs_from_handle",
					    status_line => $self->{client}->status_line,
					    method_name => 'add_contigs_from_handle',
				       );
    }
}



=head2 add_features

  $genome_out = $obj->add_features($genome_in, $features)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$features is a reference to a list where each element is a compact_feature
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
compact_feature is a reference to a list containing 5 items:
	0: (id) a string
	1: (location) a string
	2: (feature_type) a string
	3: (function) a string
	4: (aliases) a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$features is a reference to a list where each element is a compact_feature
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
compact_feature is a reference to a list containing 5 items:
	0: (id) a string
	1: (location) a string
	2: (feature_type) a string
	3: (function) a string
	4: (aliases) a string


=end text

=item Description

Add a set of features in tabular form.

=back

=cut

sub add_features
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function add_features (received $n, expecting 2)");
    }
    {
	my($genome_in, $features) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($features) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"features\" (value was \"$features\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to add_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'add_features');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.add_features",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'add_features',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method add_features",
					    status_line => $self->{client}->status_line,
					    method_name => 'add_features',
				       );
    }
}



=head2 genomeTO_to_reconstructionTO

  $return = $obj->genomeTO_to_reconstructionTO($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a reconstructionTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
reconstructionTO is a reference to a hash where the following keys are defined:
	subsystems has a value which is a variant_subsystem_pairs
	bindings has a value which is a fid_role_pairs
	assignments has a value which is a fid_function_pairs
variant_subsystem_pairs is a reference to a list where each element is a variant_of_subsystem
variant_of_subsystem is a reference to a list containing 2 items:
	0: a subsystem
	1: a variant
subsystem is a string
variant is a string
fid_role_pairs is a reference to a list where each element is a fid_role_pair
fid_role_pair is a reference to a list containing 2 items:
	0: a fid
	1: a role
fid is a string
role is a string
fid_function_pairs is a reference to a list where each element is a fid_function_pair
fid_function_pair is a reference to a list containing 2 items:
	0: a fid
	1: a function
function is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a reconstructionTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
reconstructionTO is a reference to a hash where the following keys are defined:
	subsystems has a value which is a variant_subsystem_pairs
	bindings has a value which is a fid_role_pairs
	assignments has a value which is a fid_function_pairs
variant_subsystem_pairs is a reference to a list where each element is a variant_of_subsystem
variant_of_subsystem is a reference to a list containing 2 items:
	0: a subsystem
	1: a variant
subsystem is a string
variant is a string
fid_role_pairs is a reference to a list where each element is a fid_role_pair
fid_role_pair is a reference to a list containing 2 items:
	0: a fid
	1: a role
fid is a string
role is a string
fid_function_pairs is a reference to a list where each element is a fid_function_pair
fid_function_pair is a reference to a list containing 2 items:
	0: a fid
	1: a function
function is a string


=end text

=item Description



=back

=cut

sub genomeTO_to_reconstructionTO
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genomeTO_to_reconstructionTO (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genomeTO_to_reconstructionTO:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genomeTO_to_reconstructionTO');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.genomeTO_to_reconstructionTO",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genomeTO_to_reconstructionTO',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genomeTO_to_reconstructionTO",
					    status_line => $self->{client}->status_line,
					    method_name => 'genomeTO_to_reconstructionTO',
				       );
    }
}



=head2 genomeTO_to_feature_data

  $return = $obj->genomeTO_to_feature_data($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a fid_data_tuples
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
fid_data_tuples is a reference to a list where each element is a fid_data_tuple
fid_data_tuple is a reference to a list containing 4 items:
	0: a fid
	1: a md5
	2: a location
	3: a function
fid is a string
md5 is a string
function is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a fid_data_tuples
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
fid_data_tuples is a reference to a list where each element is a fid_data_tuple
fid_data_tuple is a reference to a list containing 4 items:
	0: a fid
	1: a md5
	2: a location
	3: a function
fid is a string
md5 is a string
function is a string


=end text

=item Description



=back

=cut

sub genomeTO_to_feature_data
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genomeTO_to_feature_data (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genomeTO_to_feature_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genomeTO_to_feature_data');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.genomeTO_to_feature_data",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genomeTO_to_feature_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genomeTO_to_feature_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'genomeTO_to_feature_data',
				       );
    }
}



=head2 reconstructionTO_to_roles

  $return = $obj->reconstructionTO_to_roles($reconstructionTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$reconstructionTO is a reconstructionTO
$return is a reference to a list where each element is a role
reconstructionTO is a reference to a hash where the following keys are defined:
	subsystems has a value which is a variant_subsystem_pairs
	bindings has a value which is a fid_role_pairs
	assignments has a value which is a fid_function_pairs
variant_subsystem_pairs is a reference to a list where each element is a variant_of_subsystem
variant_of_subsystem is a reference to a list containing 2 items:
	0: a subsystem
	1: a variant
subsystem is a string
variant is a string
fid_role_pairs is a reference to a list where each element is a fid_role_pair
fid_role_pair is a reference to a list containing 2 items:
	0: a fid
	1: a role
fid is a string
role is a string
fid_function_pairs is a reference to a list where each element is a fid_function_pair
fid_function_pair is a reference to a list containing 2 items:
	0: a fid
	1: a function
function is a string

</pre>

=end html

=begin text

$reconstructionTO is a reconstructionTO
$return is a reference to a list where each element is a role
reconstructionTO is a reference to a hash where the following keys are defined:
	subsystems has a value which is a variant_subsystem_pairs
	bindings has a value which is a fid_role_pairs
	assignments has a value which is a fid_function_pairs
variant_subsystem_pairs is a reference to a list where each element is a variant_of_subsystem
variant_of_subsystem is a reference to a list containing 2 items:
	0: a subsystem
	1: a variant
subsystem is a string
variant is a string
fid_role_pairs is a reference to a list where each element is a fid_role_pair
fid_role_pair is a reference to a list containing 2 items:
	0: a fid
	1: a role
fid is a string
role is a string
fid_function_pairs is a reference to a list where each element is a fid_function_pair
fid_function_pair is a reference to a list containing 2 items:
	0: a fid
	1: a function
function is a string


=end text

=item Description



=back

=cut

sub reconstructionTO_to_roles
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function reconstructionTO_to_roles (received $n, expecting 1)");
    }
    {
	my($reconstructionTO) = @args;

	my @_bad_arguments;
        (ref($reconstructionTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"reconstructionTO\" (value was \"$reconstructionTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to reconstructionTO_to_roles:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'reconstructionTO_to_roles');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.reconstructionTO_to_roles",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'reconstructionTO_to_roles',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method reconstructionTO_to_roles",
					    status_line => $self->{client}->status_line,
					    method_name => 'reconstructionTO_to_roles',
				       );
    }
}



=head2 reconstructionTO_to_subsystems

  $return = $obj->reconstructionTO_to_subsystems($reconstructionTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$reconstructionTO is a reconstructionTO
$return is a variant_subsystem_pairs
reconstructionTO is a reference to a hash where the following keys are defined:
	subsystems has a value which is a variant_subsystem_pairs
	bindings has a value which is a fid_role_pairs
	assignments has a value which is a fid_function_pairs
variant_subsystem_pairs is a reference to a list where each element is a variant_of_subsystem
variant_of_subsystem is a reference to a list containing 2 items:
	0: a subsystem
	1: a variant
subsystem is a string
variant is a string
fid_role_pairs is a reference to a list where each element is a fid_role_pair
fid_role_pair is a reference to a list containing 2 items:
	0: a fid
	1: a role
fid is a string
role is a string
fid_function_pairs is a reference to a list where each element is a fid_function_pair
fid_function_pair is a reference to a list containing 2 items:
	0: a fid
	1: a function
function is a string

</pre>

=end html

=begin text

$reconstructionTO is a reconstructionTO
$return is a variant_subsystem_pairs
reconstructionTO is a reference to a hash where the following keys are defined:
	subsystems has a value which is a variant_subsystem_pairs
	bindings has a value which is a fid_role_pairs
	assignments has a value which is a fid_function_pairs
variant_subsystem_pairs is a reference to a list where each element is a variant_of_subsystem
variant_of_subsystem is a reference to a list containing 2 items:
	0: a subsystem
	1: a variant
subsystem is a string
variant is a string
fid_role_pairs is a reference to a list where each element is a fid_role_pair
fid_role_pair is a reference to a list containing 2 items:
	0: a fid
	1: a role
fid is a string
role is a string
fid_function_pairs is a reference to a list where each element is a fid_function_pair
fid_function_pair is a reference to a list containing 2 items:
	0: a fid
	1: a function
function is a string


=end text

=item Description



=back

=cut

sub reconstructionTO_to_subsystems
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function reconstructionTO_to_subsystems (received $n, expecting 1)");
    }
    {
	my($reconstructionTO) = @args;

	my @_bad_arguments;
        (ref($reconstructionTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"reconstructionTO\" (value was \"$reconstructionTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to reconstructionTO_to_subsystems:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'reconstructionTO_to_subsystems');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.reconstructionTO_to_subsystems",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'reconstructionTO_to_subsystems',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method reconstructionTO_to_subsystems",
					    status_line => $self->{client}->status_line,
					    method_name => 'reconstructionTO_to_subsystems',
				       );
    }
}



=head2 assign_functions_to_CDSs

  $return = $obj->assign_functions_to_CDSs($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Given a genome object populated with contig data, perform gene calling
and functional annotation and return the annotated genome.

=back

=cut

sub assign_functions_to_CDSs
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function assign_functions_to_CDSs (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to assign_functions_to_CDSs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'assign_functions_to_CDSs');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.assign_functions_to_CDSs",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'assign_functions_to_CDSs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method assign_functions_to_CDSs",
					    status_line => $self->{client}->status_line,
					    method_name => 'assign_functions_to_CDSs',
				       );
    }
}



=head2 annotate_genome

  $return = $obj->annotate_genome($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub annotate_genome
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function annotate_genome (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotate_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'annotate_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.annotate_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'annotate_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method annotate_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'annotate_genome',
				       );
    }
}



=head2 call_selenoproteins

  $return = $obj->call_selenoproteins($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_selenoproteins
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_selenoproteins (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_selenoproteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_selenoproteins');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_selenoproteins",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_selenoproteins',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_selenoproteins",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_selenoproteins',
				       );
    }
}



=head2 call_pyrrolysoproteins

  $return = $obj->call_pyrrolysoproteins($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_pyrrolysoproteins
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_pyrrolysoproteins (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_pyrrolysoproteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_pyrrolysoproteins');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_pyrrolysoproteins",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_pyrrolysoproteins',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_pyrrolysoproteins",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_pyrrolysoproteins',
				       );
    }
}



=head2 call_features_selenoprotein

  $return = $obj->call_features_selenoprotein($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Given a genome typed object, call selenoprotein features.

=back

=cut

sub call_features_selenoprotein
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_selenoprotein (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_selenoprotein:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_selenoprotein');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_selenoprotein",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_selenoprotein',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_selenoprotein",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_selenoprotein',
				       );
    }
}



=head2 call_features_pyrrolysoprotein

  $return = $obj->call_features_pyrrolysoprotein($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Given a genome typed object, call pyrrolysoprotein features.

=back

=cut

sub call_features_pyrrolysoprotein
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_pyrrolysoprotein (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_pyrrolysoprotein:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_pyrrolysoprotein');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_pyrrolysoprotein",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_pyrrolysoprotein',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_pyrrolysoprotein",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_pyrrolysoprotein',
				       );
    }
}



=head2 call_features_rRNA_SEED

  $genome_out = $obj->call_features_rRNA_SEED($genome_in, $types)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$types is a reference to a list where each element is a rna_type
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
rna_type is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$types is a reference to a list where each element is a rna_type
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
rna_type is a string


=end text

=item Description

Given a genome typed object, find instances of ribosomal RNAs in
the genome.
The types parameter is used to select the types of RNAs to
call. It is a list of strings where each value is one of
   "5S"
   "SSU"
   "LSU"
or "ALL" to choose all available rRNA types.

=back

=cut

sub call_features_rRNA_SEED
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_rRNA_SEED (received $n, expecting 2)");
    }
    {
	my($genome_in, $types) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($types) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"types\" (value was \"$types\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_rRNA_SEED:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_rRNA_SEED');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_rRNA_SEED",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_rRNA_SEED',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_rRNA_SEED",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_rRNA_SEED',
				       );
    }
}



=head2 call_features_tRNA_trnascan

  $genome_out = $obj->call_features_tRNA_trnascan($genome_in)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Given a genome typed object, find instances of tRNAs in
the genome.

=back

=cut

sub call_features_tRNA_trnascan
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_tRNA_trnascan (received $n, expecting 1)");
    }
    {
	my($genome_in) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_tRNA_trnascan:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_tRNA_trnascan');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_tRNA_trnascan",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_tRNA_trnascan',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_tRNA_trnascan",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_tRNA_trnascan',
				       );
    }
}



=head2 call_RNAs

  $genome_out = $obj->call_RNAs($genome_in)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Given a genome typed object, find instances of all RNAs we currently
have support for detecting.

=back

=cut

sub call_RNAs
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_RNAs (received $n, expecting 1)");
    }
    {
	my($genome_in) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_RNAs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_RNAs');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_RNAs",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_RNAs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_RNAs",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_RNAs',
				       );
    }
}



=head2 call_features_CDS_glimmer3

  $return = $obj->call_features_CDS_glimmer3($genomeTO, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$params is a glimmer3_parameters
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$params is a glimmer3_parameters
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int


=end text

=item Description



=back

=cut

sub call_features_CDS_glimmer3
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_CDS_glimmer3 (received $n, expecting 2)");
    }
    {
	my($genomeTO, $params) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_CDS_glimmer3:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_CDS_glimmer3');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_CDS_glimmer3",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_CDS_glimmer3',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_CDS_glimmer3",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_CDS_glimmer3',
				       );
    }
}



=head2 call_features_CDS_prodigal

  $return = $obj->call_features_CDS_prodigal($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_CDS_prodigal
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_CDS_prodigal (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_CDS_prodigal:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_CDS_prodigal');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_CDS_prodigal",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_CDS_prodigal',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_CDS_prodigal",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_CDS_prodigal',
				       );
    }
}



=head2 call_features_CDS_SEED_projection

  $return = $obj->call_features_CDS_SEED_projection($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_CDS_SEED_projection
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_CDS_SEED_projection (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_CDS_SEED_projection:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_CDS_SEED_projection');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_CDS_SEED_projection",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_CDS_SEED_projection',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_CDS_SEED_projection",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_CDS_SEED_projection',
				       );
    }
}



=head2 call_features_CDS_FragGeneScan

  $return = $obj->call_features_CDS_FragGeneScan($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_CDS_FragGeneScan
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_CDS_FragGeneScan (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_CDS_FragGeneScan:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_CDS_FragGeneScan');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_CDS_FragGeneScan",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_CDS_FragGeneScan',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_CDS_FragGeneScan",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_CDS_FragGeneScan',
				       );
    }
}



=head2 call_features_repeat_region_SEED

  $genome_out = $obj->call_features_repeat_region_SEED($genome_in, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$params is a repeat_region_SEED_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int

</pre>

=end html

=begin text

$genome_in is a genomeTO
$params is a repeat_region_SEED_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int


=end text

=item Description



=back

=cut

sub call_features_repeat_region_SEED
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_repeat_region_SEED (received $n, expecting 2)");
    }
    {
	my($genome_in, $params) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_repeat_region_SEED:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_repeat_region_SEED');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_repeat_region_SEED",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_repeat_region_SEED',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_repeat_region_SEED",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_repeat_region_SEED',
				       );
    }
}



=head2 call_features_prophage_phispy

  $genome_out = $obj->call_features_prophage_phispy($genome_in)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_prophage_phispy
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_prophage_phispy (received $n, expecting 1)");
    }
    {
	my($genome_in) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_prophage_phispy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_prophage_phispy');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_prophage_phispy",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_prophage_phispy',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_prophage_phispy",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_prophage_phispy',
				       );
    }
}



=head2 call_features_scan_for_matches

  $genome_out = $obj->call_features_scan_for_matches($genome_in, $pattern, $feature_type)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$pattern is a string
$feature_type is a string
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$pattern is a string
$feature_type is a string
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_scan_for_matches
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_scan_for_matches (received $n, expecting 3)");
    }
    {
	my($genome_in, $pattern, $feature_type) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (!ref($pattern)) or push(@_bad_arguments, "Invalid type for argument 2 \"pattern\" (value was \"$pattern\")");
        (!ref($feature_type)) or push(@_bad_arguments, "Invalid type for argument 3 \"feature_type\" (value was \"$feature_type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_scan_for_matches:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_scan_for_matches');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_scan_for_matches",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_scan_for_matches',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_scan_for_matches",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_scan_for_matches',
				       );
    }
}



=head2 annotate_proteins_kmer_v1

  $return = $obj->annotate_proteins_kmer_v1($genomeTO, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$params is a kmer_v1_parameters
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$params is a kmer_v1_parameters
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int


=end text

=item Description



=back

=cut

sub annotate_proteins_kmer_v1
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function annotate_proteins_kmer_v1 (received $n, expecting 2)");
    }
    {
	my($genomeTO, $params) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotate_proteins_kmer_v1:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'annotate_proteins_kmer_v1');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.annotate_proteins_kmer_v1",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'annotate_proteins_kmer_v1',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method annotate_proteins_kmer_v1",
					    status_line => $self->{client}->status_line,
					    method_name => 'annotate_proteins_kmer_v1',
				       );
    }
}



=head2 annotate_proteins_kmer_v2

  $genome_out = $obj->annotate_proteins_kmer_v2($genome_in, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$params is a kmer_v2_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$genome_in is a genomeTO
$params is a kmer_v2_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int


=end text

=item Description



=back

=cut

sub annotate_proteins_kmer_v2
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function annotate_proteins_kmer_v2 (received $n, expecting 2)");
    }
    {
	my($genome_in, $params) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotate_proteins_kmer_v2:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'annotate_proteins_kmer_v2');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.annotate_proteins_kmer_v2",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'annotate_proteins_kmer_v2',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method annotate_proteins_kmer_v2",
					    status_line => $self->{client}->status_line,
					    method_name => 'annotate_proteins_kmer_v2',
				       );
    }
}



=head2 resolve_overlapping_features

  $genome_out = $obj->resolve_overlapping_features($genome_in, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$params is a resolve_overlapping_features_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
resolve_overlapping_features_parameters is a reference to a hash where the following keys are defined:
	placeholder has a value which is an int

</pre>

=end html

=begin text

$genome_in is a genomeTO
$params is a resolve_overlapping_features_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
resolve_overlapping_features_parameters is a reference to a hash where the following keys are defined:
	placeholder has a value which is an int


=end text

=item Description



=back

=cut

sub resolve_overlapping_features
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function resolve_overlapping_features (received $n, expecting 2)");
    }
    {
	my($genome_in, $params) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to resolve_overlapping_features:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'resolve_overlapping_features');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.resolve_overlapping_features",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'resolve_overlapping_features',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method resolve_overlapping_features",
					    status_line => $self->{client}->status_line,
					    method_name => 'resolve_overlapping_features',
				       );
    }
}



=head2 call_features_ProtoCDS_kmer_v1

  $return = $obj->call_features_ProtoCDS_kmer_v1($genomeTO, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$params is a kmer_v1_parameters
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$params is a kmer_v1_parameters
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int


=end text

=item Description



=back

=cut

sub call_features_ProtoCDS_kmer_v1
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_ProtoCDS_kmer_v1 (received $n, expecting 2)");
    }
    {
	my($genomeTO, $params) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_ProtoCDS_kmer_v1:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_ProtoCDS_kmer_v1');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_ProtoCDS_kmer_v1",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_ProtoCDS_kmer_v1',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_ProtoCDS_kmer_v1",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_ProtoCDS_kmer_v1',
				       );
    }
}



=head2 call_features_ProtoCDS_kmer_v2

  $genome_out = $obj->call_features_ProtoCDS_kmer_v2($genome_in, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$params is a kmer_v2_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$genome_in is a genomeTO
$params is a kmer_v2_parameters
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int


=end text

=item Description

RAST-style kmers

=back

=cut

sub call_features_ProtoCDS_kmer_v2
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_ProtoCDS_kmer_v2 (received $n, expecting 2)");
    }
    {
	my($genome_in, $params) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_ProtoCDS_kmer_v2:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_ProtoCDS_kmer_v2');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_ProtoCDS_kmer_v2",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_ProtoCDS_kmer_v2',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_ProtoCDS_kmer_v2",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_ProtoCDS_kmer_v2',
				       );
    }
}



=head2 annotate_proteins

  $return = $obj->annotate_proteins($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Ross's new kmers

=back

=cut

sub annotate_proteins
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function annotate_proteins (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotate_proteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'annotate_proteins');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.annotate_proteins",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'annotate_proteins',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method annotate_proteins",
					    status_line => $self->{client}->status_line,
					    method_name => 'annotate_proteins',
				       );
    }
}



=head2 estimate_crude_phylogenetic_position_kmer

  $position_estimate = $obj->estimate_crude_phylogenetic_position_kmer($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$position_estimate is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$position_estimate is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Determine close genomes.

=back

=cut

sub estimate_crude_phylogenetic_position_kmer
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function estimate_crude_phylogenetic_position_kmer (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to estimate_crude_phylogenetic_position_kmer:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'estimate_crude_phylogenetic_position_kmer');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.estimate_crude_phylogenetic_position_kmer",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'estimate_crude_phylogenetic_position_kmer',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method estimate_crude_phylogenetic_position_kmer",
					    status_line => $self->{client}->status_line,
					    method_name => 'estimate_crude_phylogenetic_position_kmer',
				       );
    }
}



=head2 find_close_neighbors

  $return = $obj->find_close_neighbors($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub find_close_neighbors
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function find_close_neighbors (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to find_close_neighbors:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'find_close_neighbors');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.find_close_neighbors",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'find_close_neighbors',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method find_close_neighbors",
					    status_line => $self->{client}->status_line,
					    method_name => 'find_close_neighbors',
				       );
    }
}



=head2 call_features_strep_suis_repeat

  $return = $obj->call_features_strep_suis_repeat($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Interface to Strep repeats and "boxes" tools

=back

=cut

sub call_features_strep_suis_repeat
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_strep_suis_repeat (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_strep_suis_repeat:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_strep_suis_repeat');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_strep_suis_repeat",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_strep_suis_repeat',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_strep_suis_repeat",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_strep_suis_repeat',
				       );
    }
}



=head2 call_features_strep_pneumo_repeat

  $return = $obj->call_features_strep_pneumo_repeat($genomeTO)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genomeTO is a genomeTO
$return is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_strep_pneumo_repeat
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_strep_pneumo_repeat (received $n, expecting 1)");
    }
    {
	my($genomeTO) = @args;

	my @_bad_arguments;
        (ref($genomeTO) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeTO\" (value was \"$genomeTO\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_strep_pneumo_repeat:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_strep_pneumo_repeat');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_strep_pneumo_repeat",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_strep_pneumo_repeat',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_strep_pneumo_repeat",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_strep_pneumo_repeat',
				       );
    }
}



=head2 call_features_crispr

  $genome_out = $obj->call_features_crispr($genome_in)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description



=back

=cut

sub call_features_crispr
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function call_features_crispr (received $n, expecting 1)");
    }
    {
	my($genome_in) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_features_crispr:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'call_features_crispr');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.call_features_crispr",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'call_features_crispr',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method call_features_crispr",
					    status_line => $self->{client}->status_line,
					    method_name => 'call_features_crispr',
				       );
    }
}



=head2 export_genome

  $exported_data = $obj->export_genome($genome_in, $format, $feature_types)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$format is a string
$feature_types is a reference to a list where each element is a string
$exported_data is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string

</pre>

=end html

=begin text

$genome_in is a genomeTO
$format is a string
$feature_types is a reference to a list where each element is a string
$exported_data is a string
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string


=end text

=item Description

Export genome typed object to one of the supported output formats:
genbank, embl, or gff.
If feature_types is a non-empty list, limit the output to the given
feature types.

=back

=cut

sub export_genome
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function export_genome (received $n, expecting 3)");
    }
    {
	my($genome_in, $format, $feature_types) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (!ref($format)) or push(@_bad_arguments, "Invalid type for argument 2 \"format\" (value was \"$format\")");
        (ref($feature_types) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"feature_types\" (value was \"$feature_types\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to export_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'export_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.export_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'export_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method export_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'export_genome',
				       );
    }
}



=head2 enumerate_classifiers

  $return = $obj->enumerate_classifiers()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a list where each element is a string

</pre>

=end html

=begin text

$return is a reference to a list where each element is a string


=end text

=item Description

Enumerate the available classifiers. Returns the list of identifiers for
the classifiers.

=back

=cut

sub enumerate_classifiers
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function enumerate_classifiers (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.enumerate_classifiers",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'enumerate_classifiers',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method enumerate_classifiers",
					    status_line => $self->{client}->status_line,
					    method_name => 'enumerate_classifiers',
				       );
    }
}



=head2 query_classifier_groups

  $return = $obj->query_classifier_groups($classifier)

=over 4

=item Parameter and return types

=begin html

<pre>
$classifier is a string
$return is a reference to a hash where the key is a string and the value is a reference to a list where each element is a genome_id
genome_id is a string

</pre>

=end html

=begin text

$classifier is a string
$return is a reference to a hash where the key is a string and the value is a reference to a list where each element is a genome_id
genome_id is a string


=end text

=item Description

Query the groups included in the given classifier. This is a
mapping from the group name to the list of genome IDs included
in the group. Note that these are genome IDs native to the
system that created the classifier; currently these are
SEED genome IDs that may be translated using the
source IDs on the Genome entity.

=back

=cut

sub query_classifier_groups
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function query_classifier_groups (received $n, expecting 1)");
    }
    {
	my($classifier) = @args;

	my @_bad_arguments;
        (!ref($classifier)) or push(@_bad_arguments, "Invalid type for argument 1 \"classifier\" (value was \"$classifier\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to query_classifier_groups:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'query_classifier_groups');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.query_classifier_groups",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'query_classifier_groups',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method query_classifier_groups",
					    status_line => $self->{client}->status_line,
					    method_name => 'query_classifier_groups',
				       );
    }
}



=head2 query_classifier_taxonomies

  $return = $obj->query_classifier_taxonomies($classifier)

=over 4

=item Parameter and return types

=begin html

<pre>
$classifier is a string
$return is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$classifier is a string
$return is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Query the taxonomy strings that this classifier maps.

=back

=cut

sub query_classifier_taxonomies
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function query_classifier_taxonomies (received $n, expecting 1)");
    }
    {
	my($classifier) = @args;

	my @_bad_arguments;
        (!ref($classifier)) or push(@_bad_arguments, "Invalid type for argument 1 \"classifier\" (value was \"$classifier\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to query_classifier_taxonomies:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'query_classifier_taxonomies');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.query_classifier_taxonomies",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'query_classifier_taxonomies',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method query_classifier_taxonomies",
					    status_line => $self->{client}->status_line,
					    method_name => 'query_classifier_taxonomies',
				       );
    }
}



=head2 classify_into_bins

  $return = $obj->classify_into_bins($classifier, $dna_input)

=over 4

=item Parameter and return types

=begin html

<pre>
$classifier is a string
$dna_input is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna_data) a string
$return is a reference to a hash where the key is a string and the value is an int

</pre>

=end html

=begin text

$classifier is a string
$dna_input is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna_data) a string
$return is a reference to a hash where the key is a string and the value is an int


=end text

=item Description

Classify a dataset, returning only the binned output.

=back

=cut

sub classify_into_bins
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function classify_into_bins (received $n, expecting 2)");
    }
    {
	my($classifier, $dna_input) = @args;

	my @_bad_arguments;
        (!ref($classifier)) or push(@_bad_arguments, "Invalid type for argument 1 \"classifier\" (value was \"$classifier\")");
        (ref($dna_input) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"dna_input\" (value was \"$dna_input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to classify_into_bins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'classify_into_bins');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.classify_into_bins",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'classify_into_bins',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method classify_into_bins",
					    status_line => $self->{client}->status_line,
					    method_name => 'classify_into_bins',
				       );
    }
}



=head2 classify_full

  $return_1, $raw_output, $unassigned = $obj->classify_full($classifier, $dna_input)

=over 4

=item Parameter and return types

=begin html

<pre>
$classifier is a string
$dna_input is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna_data) a string
$return_1 is a reference to a hash where the key is a string and the value is an int
$raw_output is a string
$unassigned is a reference to a list where each element is a string

</pre>

=end html

=begin text

$classifier is a string
$dna_input is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna_data) a string
$return_1 is a reference to a hash where the key is a string and the value is an int
$raw_output is a string
$unassigned is a reference to a list where each element is a string


=end text

=item Description

Classify a dataset, returning the binned output along with the raw assignments and the list of
sequences that were not assigned.

=back

=cut

sub classify_full
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function classify_full (received $n, expecting 2)");
    }
    {
	my($classifier, $dna_input) = @args;

	my @_bad_arguments;
        (!ref($classifier)) or push(@_bad_arguments, "Invalid type for argument 1 \"classifier\" (value was \"$classifier\")");
        (ref($dna_input) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"dna_input\" (value was \"$dna_input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to classify_full:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'classify_full');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.classify_full",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'classify_full',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method classify_full",
					    status_line => $self->{client}->status_line,
					    method_name => 'classify_full',
				       );
    }
}



=head2 default_workflow

  $return = $obj->default_workflow()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a workflow
workflow is a reference to a hash where the following keys are defined:
	stages has a value which is a reference to a list where each element is a pipeline_stage
pipeline_stage is a reference to a hash where the following keys are defined:
	name has a value which is a string
	condition has a value which is a string
	failure_is_not_fatal has a value which is an int
	repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
	glimmer3_parameters has a value which is a glimmer3_parameters
	kmer_v1_parameters has a value which is a kmer_v1_parameters
	kmer_v2_parameters has a value which is a kmer_v2_parameters
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$return is a workflow
workflow is a reference to a hash where the following keys are defined:
	stages has a value which is a reference to a list where each element is a pipeline_stage
pipeline_stage is a reference to a hash where the following keys are defined:
	name has a value which is a string
	condition has a value which is a string
	failure_is_not_fatal has a value which is an int
	repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
	glimmer3_parameters has a value which is a glimmer3_parameters
	kmer_v1_parameters has a value which is a kmer_v1_parameters
	kmer_v2_parameters has a value which is a kmer_v2_parameters
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int


=end text

=item Description



=back

=cut

sub default_workflow
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function default_workflow (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.default_workflow",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'default_workflow',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method default_workflow",
					    status_line => $self->{client}->status_line,
					    method_name => 'default_workflow',
				       );
    }
}



=head2 run_pipeline

  $genome_out = $obj->run_pipeline($genome_in, $workflow)

=over 4

=item Parameter and return types

=begin html

<pre>
$genome_in is a genomeTO
$workflow is a workflow
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
workflow is a reference to a hash where the following keys are defined:
	stages has a value which is a reference to a list where each element is a pipeline_stage
pipeline_stage is a reference to a hash where the following keys are defined:
	name has a value which is a string
	condition has a value which is a string
	failure_is_not_fatal has a value which is an int
	repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
	glimmer3_parameters has a value which is a glimmer3_parameters
	kmer_v1_parameters has a value which is a kmer_v1_parameters
	kmer_v2_parameters has a value which is a kmer_v2_parameters
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$genome_in is a genomeTO
$workflow is a workflow
$genome_out is a genomeTO
genomeTO is a reference to a hash where the following keys are defined:
	id has a value which is a genome_id
	scientific_name has a value which is a string
	domain has a value which is a string
	genetic_code has a value which is an int
	source has a value which is a string
	source_id has a value which is a string
	taxonomy has a value which is a string
	quality has a value which is a genome_quality_measure
	contigs has a value which is a reference to a list where each element is a contig
	contigs_handle has a value which is a Handle
	features has a value which is a reference to a list where each element is a feature
	close_genomes has a value which is a reference to a list where each element is a close_genome
	analysis_events has a value which is a reference to a list where each element is an analysis_event
genome_id is a string
genome_quality_measure is a reference to a hash where the following keys are defined:
	frameshift_error_rate has a value which is a float
	sequence_error_rate has a value which is a float
contig is a reference to a hash where the following keys are defined:
	id has a value which is a contig_id
	dna has a value which is a string
	genetic_code has a value which is an int
	cell_compartment has a value which is a string
	replicon_type has a value which is a string
	replicon_geometry has a value which is a string
	complete has a value which is a bool
contig_id is a string
bool is an int
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
feature is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	location has a value which is a location
	type has a value which is a feature_type
	function has a value which is a string
	protein_translation has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
	0: (source) a string
	1: (alias) a string

	annotations has a value which is a reference to a list where each element is an annotation
	quality has a value which is a feature_quality_measure
	feature_creation_event has a value which is an analysis_event_id
feature_id is a string
location is a reference to a list where each element is a region_of_dna
region_of_dna is a reference to a list containing 4 items:
	0: a contig_id
	1: (begin) an int
	2: (strand) a string
	3: (length) an int
feature_type is a string
annotation is a reference to a list containing 4 items:
	0: (comment) a string
	1: (annotator) a string
	2: (annotation_time) an int
	3: an analysis_event_id
analysis_event_id is a string
feature_quality_measure is a reference to a hash where the following keys are defined:
	truncated_begin has a value which is a bool
	truncated_end has a value which is a bool
	existence_confidence has a value which is a float
	frameshifted has a value which is a bool
	selenoprotein has a value which is a bool
	pyrrolysylprotein has a value which is a bool
	overlap_rules has a value which is a reference to a list where each element is a string
	existence_priority has a value which is a float
	hit_count has a value which is a float
	weighted_hit_count has a value which is a float
close_genome is a reference to a hash where the following keys are defined:
	genome has a value which is a genome_id
	genome_name has a value which is a string
	closeness_measure has a value which is a float
	analysis_method has a value which is a string
analysis_event is a reference to a hash where the following keys are defined:
	id has a value which is an analysis_event_id
	tool_name has a value which is a string
	execution_time has a value which is a float
	parameters has a value which is a reference to a list where each element is a string
	hostname has a value which is a string
workflow is a reference to a hash where the following keys are defined:
	stages has a value which is a reference to a list where each element is a pipeline_stage
pipeline_stage is a reference to a hash where the following keys are defined:
	name has a value which is a string
	condition has a value which is a string
	failure_is_not_fatal has a value which is an int
	repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
	glimmer3_parameters has a value which is a glimmer3_parameters
	kmer_v1_parameters has a value which is a kmer_v1_parameters
	kmer_v2_parameters has a value which is a kmer_v2_parameters
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int


=end text

=item Description



=back

=cut

sub run_pipeline
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function run_pipeline (received $n, expecting 2)");
    }
    {
	my($genome_in, $workflow) = @args;

	my @_bad_arguments;
        (ref($genome_in) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genome_in\" (value was \"$genome_in\")");
        (ref($workflow) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"workflow\" (value was \"$workflow\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to run_pipeline:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'run_pipeline');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.run_pipeline",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'run_pipeline',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method run_pipeline",
					    status_line => $self->{client}->status_line,
					    method_name => 'run_pipeline',
				       );
    }
}



=head2 pipeline_batch_start

  $batch_id = $obj->pipeline_batch_start($genomes, $workflow)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomes is a reference to a list where each element is a pipeline_batch_input
$workflow is a workflow
$batch_id is a string
pipeline_batch_input is a reference to a hash where the following keys are defined:
	genome_id has a value which is a string
	data has a value which is a Handle
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
workflow is a reference to a hash where the following keys are defined:
	stages has a value which is a reference to a list where each element is a pipeline_stage
pipeline_stage is a reference to a hash where the following keys are defined:
	name has a value which is a string
	condition has a value which is a string
	failure_is_not_fatal has a value which is an int
	repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
	glimmer3_parameters has a value which is a glimmer3_parameters
	kmer_v1_parameters has a value which is a kmer_v1_parameters
	kmer_v2_parameters has a value which is a kmer_v2_parameters
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int

</pre>

=end html

=begin text

$genomes is a reference to a list where each element is a pipeline_batch_input
$workflow is a workflow
$batch_id is a string
pipeline_batch_input is a reference to a hash where the following keys are defined:
	genome_id has a value which is a string
	data has a value which is a Handle
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string
workflow is a reference to a hash where the following keys are defined:
	stages has a value which is a reference to a list where each element is a pipeline_stage
pipeline_stage is a reference to a hash where the following keys are defined:
	name has a value which is a string
	condition has a value which is a string
	failure_is_not_fatal has a value which is an int
	repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
	glimmer3_parameters has a value which is a glimmer3_parameters
	kmer_v1_parameters has a value which is a kmer_v1_parameters
	kmer_v2_parameters has a value which is a kmer_v2_parameters
repeat_region_SEED_parameters is a reference to a hash where the following keys are defined:
	min_identity has a value which is a float
	min_length has a value which is an int
glimmer3_parameters is a reference to a hash where the following keys are defined:
	min_training_len has a value which is an int
kmer_v1_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
kmer_v2_parameters is a reference to a hash where the following keys are defined:
	min_hits has a value which is an int
	max_gap has a value which is an int


=end text

=item Description



=back

=cut

sub pipeline_batch_start
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function pipeline_batch_start (received $n, expecting 2)");
    }
    {
	my($genomes, $workflow) = @args;

	my @_bad_arguments;
        (ref($genomes) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"genomes\" (value was \"$genomes\")");
        (ref($workflow) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"workflow\" (value was \"$workflow\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to pipeline_batch_start:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'pipeline_batch_start');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.pipeline_batch_start",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'pipeline_batch_start',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method pipeline_batch_start",
					    status_line => $self->{client}->status_line,
					    method_name => 'pipeline_batch_start',
				       );
    }
}



=head2 pipeline_batch_status

  $status = $obj->pipeline_batch_status($batch_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$batch_id is a string
$status is a pipeline_batch_status
pipeline_batch_status is a reference to a hash where the following keys are defined:
	status has a value which is a string
	submit_date has a value which is a string
	start_date has a value which is a string
	completion_date has a value which is a string
	details has a value which is a reference to a list where each element is a pipeline_batch_status_entry
pipeline_batch_status_entry is a reference to a hash where the following keys are defined:
	genome_id has a value which is a string
	status has a value which is a string
	creation_date has a value which is a string
	start_date has a value which is a string
	completion_date has a value which is a string
	stdout has a value which is a Handle
	stderr has a value which is a Handle
	output has a value which is a Handle
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string

</pre>

=end html

=begin text

$batch_id is a string
$status is a pipeline_batch_status
pipeline_batch_status is a reference to a hash where the following keys are defined:
	status has a value which is a string
	submit_date has a value which is a string
	start_date has a value which is a string
	completion_date has a value which is a string
	details has a value which is a reference to a list where each element is a pipeline_batch_status_entry
pipeline_batch_status_entry is a reference to a hash where the following keys are defined:
	genome_id has a value which is a string
	status has a value which is a string
	creation_date has a value which is a string
	start_date has a value which is a string
	completion_date has a value which is a string
	stdout has a value which is a Handle
	stderr has a value which is a Handle
	output has a value which is a Handle
Handle is a reference to a hash where the following keys are defined:
	file_name has a value which is a string
	id has a value which is a string
	type has a value which is a string
	url has a value which is a string
	remote_md5 has a value which is a string
	remote_sha1 has a value which is a string


=end text

=item Description



=back

=cut

sub pipeline_batch_status
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function pipeline_batch_status (received $n, expecting 1)");
    }
    {
	my($batch_id) = @args;

	my @_bad_arguments;
        (!ref($batch_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"batch_id\" (value was \"$batch_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to pipeline_batch_status:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'pipeline_batch_status');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "GenomeAnnotation.pipeline_batch_status",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'pipeline_batch_status',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method pipeline_batch_status",
					    status_line => $self->{client}->status_line,
					    method_name => 'pipeline_batch_status',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "GenomeAnnotation.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'pipeline_batch_status',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method pipeline_batch_status",
            status_line => $self->{client}->status_line,
            method_name => 'pipeline_batch_status',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::GenomeAnnotation::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::GenomeAnnotation::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 Handle

=over 4



=item Description

* This is a handle service handle object, used for by-reference
* passing of data files.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
file_name has a value which is a string
id has a value which is a string
type has a value which is a string
url has a value which is a string
remote_md5 has a value which is a string
remote_sha1 has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
file_name has a value which is a string
id has a value which is a string
type has a value which is a string
url has a value which is a string
remote_md5 has a value which is a string
remote_sha1 has a value which is a string


=end text

=back



=head2 bool

=over 4



=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 md5

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 md5s

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a md5
</pre>

=end html

=begin text

a reference to a list where each element is a md5

=end text

=back



=head2 genome_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 contig_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_type

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 region_of_dna

=over 4



=item Description

A region of DNA is maintained as a tuple of four components:

                the contig
                the beginning position (from 1)
                the strand
                the length

           We often speak of "a region".  By "location", we mean a sequence
           of regions from the same genome (perhaps from distinct contigs).

           Strand is either '+' or '-'.


=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: a contig_id
1: (begin) an int
2: (strand) a string
3: (length) an int

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: a contig_id
1: (begin) an int
2: (strand) a string
3: (length) an int


=end text

=back



=head2 location

=over 4



=item Description

a "location" refers to a sequence of regions


=item Definition

=begin html

<pre>
a reference to a list where each element is a region_of_dna
</pre>

=end html

=begin text

a reference to a list where each element is a region_of_dna

=end text

=back



=head2 analysis_event_id

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 analysis_event

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is an analysis_event_id
tool_name has a value which is a string
execution_time has a value which is a float
parameters has a value which is a reference to a list where each element is a string
hostname has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is an analysis_event_id
tool_name has a value which is a string
execution_time has a value which is a float
parameters has a value which is a reference to a list where each element is a string
hostname has a value which is a string


=end text

=back



=head2 annotation

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: (comment) a string
1: (annotator) a string
2: (annotation_time) an int
3: an analysis_event_id

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: (comment) a string
1: (annotator) a string
2: (annotation_time) an int
3: an analysis_event_id


=end text

=back



=head2 feature_quality_measure

=over 4



=item Description

* The numeric priority of this feature's right to exist. Specialty
* tools will give the features they create a high priority; more generic
* tools will give their features a lower priority. The overlap removal procedure
* will use this priority to determine which of a set of overlapping features
* should be removed.
*
* The intent is that a change of 1 in the priority value represents a factor of 2 in
* preference.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
truncated_begin has a value which is a bool
truncated_end has a value which is a bool
existence_confidence has a value which is a float
frameshifted has a value which is a bool
selenoprotein has a value which is a bool
pyrrolysylprotein has a value which is a bool
overlap_rules has a value which is a reference to a list where each element is a string
existence_priority has a value which is a float
hit_count has a value which is a float
weighted_hit_count has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
truncated_begin has a value which is a bool
truncated_end has a value which is a bool
existence_confidence has a value which is a float
frameshifted has a value which is a bool
selenoprotein has a value which is a bool
pyrrolysylprotein has a value which is a bool
overlap_rules has a value which is a reference to a list where each element is a string
existence_priority has a value which is a float
hit_count has a value which is a float
weighted_hit_count has a value which is a float


=end text

=back



=head2 feature

=over 4



=item Description

A feature object represents a feature on the genome. It contains 
the location on the contig with a type, the translation if it
represents a protein, associated aliases, etc. It also contains
information gathered during the annotation process that is involved
in stages that perform overlap removal, quality testing, etc.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a feature_id
location has a value which is a location
type has a value which is a feature_type
function has a value which is a string
protein_translation has a value which is a string
aliases has a value which is a reference to a list where each element is a string
alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
0: (source) a string
1: (alias) a string

annotations has a value which is a reference to a list where each element is an annotation
quality has a value which is a feature_quality_measure
feature_creation_event has a value which is an analysis_event_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a feature_id
location has a value which is a location
type has a value which is a feature_type
function has a value which is a string
protein_translation has a value which is a string
aliases has a value which is a reference to a list where each element is a string
alias_pairs has a value which is a reference to a list where each element is a reference to a list containing 2 items:
0: (source) a string
1: (alias) a string

annotations has a value which is a reference to a list where each element is an annotation
quality has a value which is a feature_quality_measure
feature_creation_event has a value which is an analysis_event_id


=end text

=back



=head2 contig

=over 4



=item Description

circular / linear


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a contig_id
dna has a value which is a string
genetic_code has a value which is an int
cell_compartment has a value which is a string
replicon_type has a value which is a string
replicon_geometry has a value which is a string
complete has a value which is a bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a contig_id
dna has a value which is a string
genetic_code has a value which is an int
cell_compartment has a value which is a string
replicon_type has a value which is a string
replicon_geometry has a value which is a string
complete has a value which is a bool


=end text

=back



=head2 close_genome

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome has a value which is a genome_id
genome_name has a value which is a string
closeness_measure has a value which is a float
analysis_method has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome has a value which is a genome_id
genome_name has a value which is a string
closeness_measure has a value which is a float
analysis_method has a value which is a string


=end text

=back



=head2 genome_quality_measure

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
frameshift_error_rate has a value which is a float
sequence_error_rate has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
frameshift_error_rate has a value which is a float
sequence_error_rate has a value which is a float


=end text

=back



=head2 genomeTO

=over 4



=item Description

All of the information about particular genome


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a genome_id
scientific_name has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
source has a value which is a string
source_id has a value which is a string
taxonomy has a value which is a string
quality has a value which is a genome_quality_measure
contigs has a value which is a reference to a list where each element is a contig
contigs_handle has a value which is a Handle
features has a value which is a reference to a list where each element is a feature
close_genomes has a value which is a reference to a list where each element is a close_genome
analysis_events has a value which is a reference to a list where each element is an analysis_event

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a genome_id
scientific_name has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
source has a value which is a string
source_id has a value which is a string
taxonomy has a value which is a string
quality has a value which is a genome_quality_measure
contigs has a value which is a reference to a list where each element is a contig
contigs_handle has a value which is a Handle
features has a value which is a reference to a list where each element is a feature
close_genomes has a value which is a reference to a list where each element is a close_genome
analysis_events has a value which is a reference to a list where each element is an analysis_event


=end text

=back



=head2 genome_metadata

=over 4



=item Description

* Genome metadata. We use this structure to define common metadata
* settings used in the API calls below. It's possible this data should
* have been separated in this way in the genome object itself, but there
* is an extant body of code that assumes the current structure of the genome
* object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a genome_id
scientific_name has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
source has a value which is a string
source_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a genome_id
scientific_name has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
source has a value which is a string
source_id has a value which is a string


=end text

=back



=head2 subsystem

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 variant

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 variant_of_subsystem

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: a subsystem
1: a variant

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: a subsystem
1: a variant


=end text

=back



=head2 variant_subsystem_pairs

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a variant_of_subsystem
</pre>

=end html

=begin text

a reference to a list where each element is a variant_of_subsystem

=end text

=back



=head2 fid

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 role

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 function

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fid_role_pair

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: a fid
1: a role

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: a fid
1: a role


=end text

=back



=head2 fid_role_pairs

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fid_role_pair
</pre>

=end html

=begin text

a reference to a list where each element is a fid_role_pair

=end text

=back



=head2 fid_function_pair

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 2 items:
0: a fid
1: a function

</pre>

=end html

=begin text

a reference to a list containing 2 items:
0: a fid
1: a function


=end text

=back



=head2 fid_function_pairs

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fid_function_pair
</pre>

=end html

=begin text

a reference to a list where each element is a fid_function_pair

=end text

=back



=head2 reconstructionTO

=over 4



=item Description

Metabolic reconstruction
represents the set of subsystems that we infer are present in this genome


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
subsystems has a value which is a variant_subsystem_pairs
bindings has a value which is a fid_role_pairs
assignments has a value which is a fid_function_pairs

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
subsystems has a value which is a variant_subsystem_pairs
bindings has a value which is a fid_role_pairs
assignments has a value which is a fid_function_pairs


=end text

=back



=head2 fid_data_tuple

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: a fid
1: a md5
2: a location
3: a function

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: a fid
1: a md5
2: a location
3: a function


=end text

=back



=head2 fid_data_tuples

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a fid_data_tuple
</pre>

=end html

=begin text

a reference to a list where each element is a fid_data_tuple

=end text

=back



=head2 compact_feature

=over 4



=item Description

* This tuple defines a compact form for defining features to be batch-loaded
* into a genome object.


=item Definition

=begin html

<pre>
a reference to a list containing 5 items:
0: (id) a string
1: (location) a string
2: (feature_type) a string
3: (function) a string
4: (aliases) a string

</pre>

=end html

=begin text

a reference to a list containing 5 items:
0: (id) a string
1: (location) a string
2: (feature_type) a string
3: (function) a string
4: (aliases) a string


=end text

=back



=head2 rna_type

=over 4



=item Description

[ validate.enum("5S", "SSU", "LSU", "ALL") ]


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 glimmer3_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
min_training_len has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
min_training_len has a value which is an int


=end text

=back



=head2 repeat_region_SEED_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
min_identity has a value which is a float
min_length has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
min_identity has a value which is a float
min_length has a value which is an int


=end text

=back



=head2 kmer_v1_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
kmer_size has a value which is an int
dataset_name has a value which is a string
return_scores_for_all_proteins has a value which is an int
score_threshold has a value which is an int
hit_threshold has a value which is an int
sequential_hit_threshold has a value which is an int
detailed has a value which is an int
min_hits has a value which is an int
min_size has a value which is an int
max_gap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
kmer_size has a value which is an int
dataset_name has a value which is a string
return_scores_for_all_proteins has a value which is an int
score_threshold has a value which is an int
hit_threshold has a value which is an int
sequential_hit_threshold has a value which is an int
detailed has a value which is an int
min_hits has a value which is an int
min_size has a value which is an int
max_gap has a value which is an int


=end text

=back



=head2 kmer_v2_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
min_hits has a value which is an int
max_gap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
min_hits has a value which is an int
max_gap has a value which is an int


=end text

=back



=head2 resolve_overlapping_features_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
placeholder has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
placeholder has a value which is an int


=end text

=back



=head2 pipeline_stage

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
condition has a value which is a string
failure_is_not_fatal has a value which is an int
repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
glimmer3_parameters has a value which is a glimmer3_parameters
kmer_v1_parameters has a value which is a kmer_v1_parameters
kmer_v2_parameters has a value which is a kmer_v2_parameters

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
condition has a value which is a string
failure_is_not_fatal has a value which is an int
repeat_region_SEED_parameters has a value which is a repeat_region_SEED_parameters
glimmer3_parameters has a value which is a glimmer3_parameters
kmer_v1_parameters has a value which is a kmer_v1_parameters
kmer_v2_parameters has a value which is a kmer_v2_parameters


=end text

=back



=head2 workflow

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
stages has a value which is a reference to a list where each element is a pipeline_stage

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
stages has a value which is a reference to a list where each element is a pipeline_stage


=end text

=back



=head2 pipeline_batch_input

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_id has a value which is a string
data has a value which is a Handle

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_id has a value which is a string
data has a value which is a Handle


=end text

=back



=head2 pipeline_batch_status_entry

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_id has a value which is a string
status has a value which is a string
creation_date has a value which is a string
start_date has a value which is a string
completion_date has a value which is a string
stdout has a value which is a Handle
stderr has a value which is a Handle
output has a value which is a Handle

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_id has a value which is a string
status has a value which is a string
creation_date has a value which is a string
start_date has a value which is a string
completion_date has a value which is a string
stdout has a value which is a Handle
stderr has a value which is a Handle
output has a value which is a Handle


=end text

=back



=head2 pipeline_batch_status

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
status has a value which is a string
submit_date has a value which is a string
start_date has a value which is a string
completion_date has a value which is a string
details has a value which is a reference to a list where each element is a pipeline_batch_status_entry

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
status has a value which is a string
submit_date has a value which is a string
start_date has a value which is a string
completion_date has a value which is a string
details has a value which is a reference to a list where each element is a pipeline_batch_status_entry


=end text

=back



=cut

package Bio::KBase::GenomeAnnotation::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
