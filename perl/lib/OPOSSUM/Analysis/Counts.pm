=head1 NAME

OPOSSUM::Analysis::Counts - Object to store the count of TFBS hits on the
gene pair sequences

=head1 SYNOPSIS

$aca = $db_adaptor->get_AnalysisCountsAdaptor();

$counts = $aca->fetch_counts(
			-conservation_level	=> 2,
			-threshold_level	=> 3,
			-search_region_level	=> 1);

=head1 DESCRIPTION

This object stores a count of the number of times each TF profile was
found on each gene pair. These counts can be retrieved from the database
by the OPOSSUM::DBSQL::Analysis::CountsAdaptor. This object can be passed to
the OPOSSUM::Analysis::Fisher and OPOSSUM::Analysis::Zscore modules.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

 Modified by Shannan Ho Sui on Dec 21, 2006 to accommodate schema changes

=head1 METHODS

=cut

package OPOSSUM::Analysis::Counts;

use strict;

use Carp;

=head2 new

 Title    : new
 Usage    : $counts = OPOSSUM::Analysis::Counts->new(
			-gene_pair_ids	        	=> $ppids,
			-tf_ids 			=> $tfids,
			-tf_info_set			=> $tfi_set,
			-conserved_region_length_set	=> $crl_set);
 Function : Create a new OPOSSUM::Analysis::Counts object.
 Returns  : An OPOSSUM::Analysis::Counts object.
 Args     : gene_pair_ids	- optionally specify a reference to a
 				  list of gene pair IDs
	    tf_ids		- optionally specify a reference to a
 				  list of TF IDs
	    tf_info_set 	- optionally specify a TFInfoSet object
	    conserved_region_length_set
	    			- optionally specify a
	    			  ConservedRegionLengthSet object

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
			_params				=> {},
    			_counts				=> {},
			-gene_pair_ids  		=> undef,
			-tf_ids 			=> undef,
			-conserved_region_length_set	=> undef,
			-tf_info_set			=> undef,
			%args
		    }, ref $class || $class;

    return $self;
}

=head2 param

 Title    : param
 Usage    : $val = $counts->param($param)
	    or $counts->param($param, $value);
 Function : Get/set a value of a counts parameter.
 Returns  : The value of the names parameter.
 Args     : The name of the parameter to get/set.
 	    optionally the value of the parameter.

=cut

sub param
{
    my ($self, $param, $value) = @_;

    if ($param) {
	if (defined $value) {
	    $self->{_params}->{$param} = $value;
	}
	return $self->{_params}->{$param};
    }
    return keys %{$self->{_params}};
}

=head2 gene_pair_ids

 Title    : gene_pair_ids
 Usage    : $gpids = $counts->gene_pair_ids()
	    or $counts->gene_pair_ids($gpids);
 Function : Get/set the list of gene pair IDs.
 Returns  : A reference to a list of gene pair IDs.
 Args     : Optionally a reference to a list of gene pair IDs.

=cut

sub gene_pair_ids
{
    my ($self, $gpids) = @_;
   
    if ($gpids) {
    	$self->{-gene_pair_ids} = $gpids;
    }
    return $self->{-gene_pair_ids}
}

=head2 get_all_gene_ids

 Title    : get_all_gene_ids
 Usage    : $gids = $counts->get_all_gene_ids()
 Function : Get the list of gene IDs. This is a synonym for the
 	    get variant of the gene_pair_ids method.
 Returns  : A reference to a list of gene IDs.
 Args     : None.

=cut

sub get_all_gene_ids
{
    my $self = shift;

    return $self->gene_pair_ids;
}

=head2 tf_ids

 Title    : tf_ids
 Usage    : $tfids = $counts->tf_ids()
	    or $counts->tf_ids($tfids);
 Function : Get/set the list of TF IDs.
 Returns  : A reference to a list of TF IDs.
 Args     : Optionally a reference to a list of TF IDs.

=cut

sub tf_ids
{
    my ($self, $tfids) = @_;
   
    if ($tfids) {
    	$self->{-tf_ids} = $tfids;
    }
    return $self->{-tf_ids}
}

=head2 get_all_tf_ids

 Title    : get_all_tf_ids
 Usage    : $tfids = $counts->get_all_tf_ids()
 Function : Get the list of TF IDs. This is a synonym for the get
 	    variant of the tf_ids method.
 Returns  : A reference to a list of TF IDs.
 Args     : Optionally a reference to a list of TF IDs.

=cut

sub get_all_tf_ids
{
    my $self = shift;

    return $self->tf_ids;
}

=head2 conserved_region_length_set

 Title    : conserved_region_length_set
 Usage    : $crl_set = $counts->conserved_region_length_set()
	    or $counts->conserved_region_length_set($crl_set);
 Function : Get/set the conserved region length set.
 Returns  : An OPOSSUM::ConservedRegionLengthSet object.
 Args     : Optionally an OPOSSUM::ConservedRegionLengthSet object.

=cut

sub conserved_region_length_set
{
    my ($self, $crl_set) = @_;
   
    if ($crl_set) {
    	$self->{-conserved_region_length_set} = $crl_set;
    }
    return $self->{-conserved_region_length_set}
}

=head2 get_conserved_region_length

 Title    : get_conserved_region_length
 Usage    : $crl = $counts->get_conserved_region_length($crl_id)
 Function : Get the ConservedRegionLength object from the
 	    ConservedRegionLengthSet by its ID.
 Returns  : An OPOSSUM::ConservedRegionLength object.
 Args     : A ConservedRegionLength ID. 

=cut

sub get_conserved_region_length 
{ 
    my ($self, $crl_id) = @_;
 
    return if !$crl_id;
    
    return $self->conserved_region_length_set($crl_id);
}

=head2 tf_info_set

 Title    : tf_info_set
 Usage    : $tfi_set = $counts->tf_info_set()
	    or $counts->tf_info_set($tfi_set);
 Function : Get/set the TF info set.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args     : Optionally an OPOSSUM::TFInfoSet object.

=cut

sub tf_info_set
{
    my ($self, $tfi_set) = @_;
   
    if ($tfi_set) {
    	$self->{-tf_info_set} = $tfi_set;
    }
    return $self->{-tf_info_set}
}

=head2 get_tf_info

 Title    : get_tf_info
 Usage    : $tf_info = $counts->get_tf_info($tf_id)
 Function : Get the TFInfo object from the TFInfoSet by its ID.
 Returns  : An OPOSSUM::TFInfo object.
 Args     : A TF ID.

=cut

sub get_tf_info
{
    my ($self, $tf_id) = @_;
   
    return if !$tf_id;

    return $self->tf_info_set($tf_id);
}

=head2 num_genes

 Title    : num_genes
 Usage    : $num = $counts->num_genes()
 Function : Get the number of genes/promoters in the counts object
 Returns  : An integer.
 Args     : None.

=cut

sub num_genes
{
    return scalar @{$_[0]->gene_pair_ids};
}

=head2 num_tfs

 Title    : num_tfs
 Usage    : $num = $counts->num_tfs()
 Function : Get the number of TFs in the counts object
 Returns  : An integer.
 Args     : None.

=cut

sub num_tfs
{
    return scalar @{$_[0]->tf_ids};
}

=head2 gene_exists

 Title    : gene_exists
 Usage    : $bool = $counts->gene_exists($id)
 Function : Return whether the gene/promoter with the given ID exists in
 	    the counts object.
 Returns  : Boolean.
 Args     : Gene/promoter ID.

=cut

sub gene_exists
{
    my ($self, $id) = @_;

    return grep /^$id$/, @{$self->gene_pair_ids};
}

=head2 tf_exists

 Title    : tf_exists
 Usage    : $bool = $counts->tf_exists($id)
 Function : Return whether sites for the TF with the given ID exists in
 	    the counts object.
 Returns  : Boolean.
 Args     : TF ID.

=cut

sub tf_exists
{
    my ($self, $id) = @_;

    return grep /^$id$/, @{$self->tf_ids};
}

=head2 exists

 Title    : exists
 Usage    : $bool = $counts->exists($gene_id, $tf_id)
 Function : Return whether the gene (promoter)/TF pair with the given
 	    IDs exist in the counts object.
 Returns  : Boolean.
 Args     : A gene (promoter) ID and a TF ID.

=cut

sub exists
{
    my ($self, $gene_id, $tf_id) = @_;

    return $self->gene_exists($gene_id) && $self->tf_exists($tf_id);
}

=head2 total_cr_length

 Title    : total_cr_length
 Usage    : $length = $counts->total_cr_length()
 Function : Return the total length of the conserved regions in the
 	    conserved region length set.
 Returns  : An integer.
 Args     : None.

=cut

sub total_cr_length
{
    return $_[0]->conserved_region_length_set->total_conserved_region_length;
}

=head2 tfbs_width

 Title    : tfbs_width
 Usage    : $width = $counts->tfbs_width($tf_id)
 Function : Return the width of the specified TF binding site.
 Returns  : An integer.
 Args     : A TF ID.

=cut

sub tfbs_width
{
    my ($self, $tf_id) = @_;

    return if !$tf_id;

    if (defined $self->tf_info_set->get_tf_info($tf_id)) {
	return $self->tf_info_set->get_tf_info($tf_id)->width;
    }
    return 0;
}

=head2 gene_tfbs_count

 Title    : gene_tfbs_count
 Usage    : $count = $counts->gene_tfbs_count($gene_id, $tf_id)
 	    or $counts->gene_tfbs_count($gene_id, $tf_id, $count)
 Function : Get/set the count of the number of times sites for the given TF
 	    were detected for the given gene (promoter).
 Returns  : An integer.
 Args     : A gene ID,
 	    a TF ID, 
	    optionally a count.

=cut

sub gene_tfbs_count
{
    my ($self, $gene_id, $tf_id, $count) = @_;

    return if !$gene_id || !$tf_id;

    #my $exists = $self->exists($gene_id, $tf_id);
    if (defined $count) {
	#if (!$exists) {
	#    carp "attempt to set count for non-existing gene/TFBS ID pair"
	#	    . " $gene_id/$tf_id\n";
	#    return;
	#} else {
	    $self->{_counts}->{"$gene_id:$tf_id"} = $count;
	#}
    }

    return $self->{_counts}->{"$gene_id:$tf_id"} || 0;
}

=head2 tfbs_gene_count

 Title    : tfbs_gene_count
 Usage    : $count = $counts->tfbs_gene_count($tf_id)
 Function : Get the count of the number of genes (promoters) for which
 	    sites for the given TF were detected.
 Returns  : An integer.
 Args     : A TF ID. 

=cut

sub tfbs_gene_count
{
    my ($self, $tf_id) = @_;

    return if !$tf_id;

    my $gene_count = 0;
    foreach my $gene_id (@{$self->gene_pair_ids}) {
	$gene_count += $self->{_counts}->{"$gene_id:$tf_id"} ? 1 : 0;
    }

    return $gene_count;
}

=head2 tfbs_gene_ids

 Title    : tfbs_gene_ids
 Usage    : $ids = $counts->tfbs_gene_ids($tf_id)
 Function : Get the list of gene (promoter) IDs for which sites for 
            the given TF were detected.
 Returns  : A ref to a list of gene (promoter) IDs.
 Args     : A TF ID. 

=cut

sub tfbs_gene_ids
{
    my ($self, $tf_id) = @_;

    return if !$tf_id;

    my @tfbs_gene_ids;
    foreach my $gene_id (@{$self->gene_pair_ids}) {
	if ($self->{_counts}->{"$gene_id:$tf_id"}) {
	    push @tfbs_gene_ids, $gene_id;
	}
    }

    return @tfbs_gene_ids ? \@tfbs_gene_ids : undef;
}

=head2 tfbs_count

 Title    : tfbs_count
 Usage    : $count = $counts->tfbs_count($tf_id)
 Function : Get the total number of times sites for the given TF appear
            for all the genes (promoters) in the counts object.
 Returns  : An integer.
 Args     : A TF ID. 

=cut

sub tfbs_count
{
    my ($self, $tf_id) = @_;

    return if !$tf_id;

    my $count = 0;
    foreach my $gene_id (@{$self->gene_pair_ids}) {
	$count += $self->{_counts}->{"$gene_id:$tf_id"} || 0;
    }

    return $count;
}

=head2 missing_gene_ids

 Title    : missing_gene_ids
 Usage    : $ids = $counts->missing_gene_ids()
 Function : Get a list of missing gene IDs. For convenience, the counts
 	    object allows storage of genes which may have been entered
	    for analysis but could not be found in the database.
 Returns  : A ref to a list of gene IDs.
 Args     : None.

=cut

sub missing_gene_ids
{
    $_[0]->{-missing_gene_ids};
}

=head2 missing_tf_ids

 Title    : missing_tf_ids
 Usage    : $ids = $counts->missing_tf_ids()
 Function : Get a list of missing TF IDs. For convenience, the counts
 	    object allows storage of TFs which may have been entered
	    for analysis but could not be found in the database.
 Returns  : A ref to a list of TF IDs.
 Args     : None.

=cut

sub missing_tf_ids
{
    $_[0]->{-missing_tf_ids};
}

=head2 subset

 Title    : subset
 Usage    : $counts_subset = $counts->subset(
				    -gene_ids	=> $gene_ids,
				    -tf_ids	=> $tf_ids);
	    OR
 	    $counts_subset = $counts->subset(
				    -gene_start	=> $gene_start,
				    -gene_end	=> $gene_end,
				    -tf_start	=> $tf_start,
				    -tf_end	=> $tf_end);
	    OR some combination of above.
 Function : Get a new counts object from the current one with only a
	    subset of the TFs and/or genes. The subset of TFs and 
	    genes may be either specified with explicit ID lists or by
	    starting and/or ending IDs.
 Returns  : A new OPOSSUM::Analysis::Counts object.
 Args     : gene_ids	- optionally a list ref of gene IDs,
 	    tf_ids	- optionally a list ref of TF IDs,
	    gene_start	- optionally the starting gene ID,
	    gene_end	- optionally the ending gene ID,
	    tf_start	- optionally the starting TFBS ID,
	    tf_end	- optionally the ending TFBS ID.

=cut

sub subset
{
    my ($self, %args) = @_;

    my $gene_start = $args{-gene_start};
    my $gene_end = $args{-gene_end};
    my $gene_ids = $args{-gene_ids};
    my $tf_start = $args{-tf_start};
    my $tf_end = $args{-tf_end};
    my $tf_ids = $args{-tf_ids};

    my $all_gene_ids = $self->gene_pair_ids;
    my $all_tf_ids = $self->tf_ids;

    my $subset_gene_ids;
    my $subset_tf_ids;

    my @missing_gene_ids;
    my @missing_tf_ids;

    if (!defined $gene_ids) {
    	if (!$gene_start && !$gene_end) {
	    $subset_gene_ids = $all_gene_ids;
	} else {
	    if (!$gene_start) {
	       $gene_start = $all_gene_ids->[0];
	    }
	    if (!$gene_end) {
	       $gene_end = $all_gene_ids->[scalar @$all_gene_ids - 1];
	    }
	    foreach my $gene_id (@$all_gene_ids) {
	    	if ($gene_id ge $gene_start && $gene_id le $gene_end) {
		    push @$subset_gene_ids, $gene_id;
		}
	    }
	}
    } else {
    	foreach my $gene_id (@$gene_ids) {
	    if (grep(/^$gene_id$/, @$all_gene_ids)) {
	    	push @$subset_gene_ids, $gene_id;
	    } else {
	    	carp "warning: gene ID $gene_id not in super set,"
			. " omitting from subset";
		push @missing_gene_ids, $gene_id;
	    }
	}
    }

    if (!defined $tf_ids) {
    	if (!$tf_start && !$tf_end) {
	    $subset_tf_ids = $all_tf_ids;
	} else {
	    if (!$tf_start) {
	       $tf_start = $all_tf_ids->[0];
	    }
	    if (!$tf_end) {
	       $tf_end = $all_tf_ids->[scalar @$all_tf_ids - 1];
	    }
	    foreach my $tf_id (@$all_tf_ids) {
	    	if ($tf_id ge $tf_start && $tf_id le $tf_end) {
		    push @$subset_tf_ids, $tf_id;
		}
	    }
	}
    } else {
    	foreach my $tf_id (@$tf_ids) {
	    if (grep(/^$tf_id$/, @$all_tf_ids)) {
	    	push @$subset_tf_ids, $tf_id;
	    } else {
	    	carp "warning: TF ID $tf_id not in super set,"
			. " omitting from subset";
		push @missing_tf_ids, $tf_id;
	    }
	}
    }

    my $subset = OPOSSUM::Analysis::Counts->new(
		    -gene_pair_ids	=> $subset_gene_ids,
		    -tf_ids		=> $subset_tf_ids,
		    -conserved_region_length_set
		    			=> $self->conserved_region_length_set
					    ->subset($subset_gene_ids),
		    -tf_info_set	=> $self->tf_info_set
					    ->subset($subset_tf_ids)
		);
    return if !$subset;

    foreach my $gene_id (@$subset_gene_ids) {
	foreach my $tf_id (@$subset_tf_ids) {
	    $subset->gene_tfbs_count($gene_id, $tf_id,
	    		$self->gene_tfbs_count($gene_id, $tf_id));
	}
    }

    $subset->{-missing_gene_ids}
			    = @missing_gene_ids ? \@missing_gene_ids : undef;
    $subset->{-missing_tf_ids}
			    = @missing_tf_ids ? \@missing_tf_ids : undef;

    return $subset;
}

1;
