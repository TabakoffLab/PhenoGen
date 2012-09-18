=head1 NAME

OPOSSUM::DBSQL::ConservedRegionAdaptor - Adaptor for MySQL queries to retrieve
and store conserved regions.

=head1 SYNOPSIS

$cra = $db_adaptor->get_ConservedRegionAdaptor();

=head1 CHANGE HISTORY

 DJA 2007/01/29
 - modified fetch_set_by_upstream_downstream and
   fetch_list_by_upstream_downstream methods to fetch and truncate
   boundaries of conserved regions on a per search region basis.
 - added new method fetch_length_by_upstream_downstream
 - created new internal routine _define_search_regions

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::ConservedRegionAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::ConservedRegion;
use OPOSSUM::ConservedRegionSet;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

=head2 new

 Title    : new
 Usage    : $cra = OPOSSUM::DBSQL::ConservedRegionAdaptor->new(@args);
 Function : Create a new ConservedRegionAdaptor.
 Returns  : A new OPOSSUM::DBSQL::ConservedRegionAdaptor object.
 Args	  : An OPOSSUM::DBSQL::DBConnection object.

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_by_gene_pair_id

 Title    : fetch_by_gene_pair_id
 Usage    : $regions = $cra->fetch_by_gene_pair_id($gpid, $cons_level);
 Function : Alias for fetch_list_by_gene_pair_id.
 Returns  : A listref of OPOSSUM::ConservedRegion objects.
 Args	  : Gene pair ID,
	    Conservation level

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $gpid, $level) = @_;

    return $self->fetch_list_by_gene_pair_id($gpid, $level);
}


=head2 fetch_list_by_gene_pair_id

 Title    : fetch_list_by_gene_pair_id
 Usage    : $regions = $cra->fetch_list_by_gene_pair_id($gpid, $cons_level);
 Function : Fetch the list of conserved regions for a given gene pair
 	    at the given level of conservation from the DB.
 Returns  : A listref of OPOSSUM::ConservedRegion objects.
 Args	  : Gene pair ID,
	    Conservation level

=cut

sub fetch_list_by_gene_pair_id
{
    my ($self, $gpid, $level) = @_;

    if (!$gpid) {
        carp "must provide gene pair ID";
	return;
    }

    if (!$level) {
        carp "must provide conservation level";
	return;
    }

    my $gpa = $self->db->get_GenePairAdaptor;
    if (!$gpa) {
        carp "error getting GenePairAdaptor";
        return;
    }

    my $sql = qq{select start1,
			end1,
			start2,
			end2,
			rel_start1,
			rel_end1,
			rel_start2,
			rel_end2,
			conservation_level,
			conservation
		from conserved_regions
		where gene_pair_id = $gpid
		and conservation_level = $level
		order by start1
	    };


    my $sth = $self->prepare($sql);
    if (!$sth) {
	my $error = "ERROR preparing fetch conserved region for GenePair $gpid"
			. " at conservation level $level";
	carp $error . "\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	my $error = "ERROR executing fetch conserved region for GenePair $gpid"
			. " at conservation level $level";
	carp $error . "\n" . $self->errstr;
	return;
    }

    my @regions;
    while (my @row = $sth->fetchrow_array) {
	push @regions, OPOSSUM::ConservedRegion->new(
				    -gene_pair_id	=> $gpid,
				    -start1		=> $row[0],
				    -end1		=> $row[1],
				    -start2		=> $row[2],
				    -end2		=> $row[3],
				    -rel_start1		=> $row[4],
				    -rel_end1		=> $row[5],
				    -rel_start2		=> $row[6],
				    -rel_end2		=> $row[7],
				    -level		=> $row[8],
				    -conservation	=> $row[9]);
    }
    $sth->finish;

    return @regions ? \@regions : undef;
}

=head2 fetch_set_by_gene_pair_id

 Title    : fetch_set_by_gene_pair_id
 Usage    : $cr_set = $cra->fetch_set_by_gene_pair_id($gpid, $level);
 Function : Fetch the set of conserved regions for a given gene pair
 	    at the given level of conservation from the DB.
 Returns  : An OPOSSUM::ConservedRegionSet object.
 Args	  : Integer gene pair ID and integer conservation level.

=cut

sub fetch_set_by_gene_pair_id
{
    my ($self, $gpid, $level) = @_;

    return if !$gpid;

    $level = 1 if !$level;

    my $sql = qq{
		select start1,
			end1,
			start2,
			end2,
			rel_start1,
			rel_end1,
			rel_start2,
			rel_end2,
			conservation_level,
			conservation
		from conserved_regions
		where gene_pair_id = $gpid
		and conservation_level = $level
		order by start1";
	    };


    my $sth = $self->prepare($sql);
    if (!$sth) {
	my $error = "ERROR preparing fetch conserved region for GenePair $gpid"
			. " at conservation level $level";
	carp $error . "\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	my $error = "ERROR executing fetch conserved region for GenePair $gpid"
			. " at conservation level $level";
	carp $error . "\n" . $self->errstr;
	return;
    }

    my $cr_set = OPOSSUM::ConservedRegionSet->new;
    $cr_set->param('gene_pair_id', $gpid);
    $cr_set->param('conservation_level', $level);

    while (my @row = $sth->fetchrow_array) {
	$cr_set->add_conserved_region(
			OPOSSUM::ConservedRegion->new(
				    -gene_pair_id	=> $gpid,
				    -start1		=> $row[0],
				    -end1		=> $row[1],
				    -start2		=> $row[2],
				    -end2		=> $row[3],
				    -rel_start1		=> $row[4],
				    -rel_end1		=> $row[5],
				    -rel_start2		=> $row[6],
				    -rel_end2		=> $row[7],
				    -level		=> $row[8],
				    -conservation	=> $row[9])
	);
    }
    $sth->finish;

    return $cr_set;
}

=head2 fetch_by_upstream_downstream

 Title    : fetch_by_upstream_downstream
 Usage    : $regions = $cra->fetch_by_upstream_downstream(
				$gpid, $cons_level, $upstream_bp,
				$downstream_bp);
 Function : Alias for fetch_list_by_upstream_downstream.
 Returns  : A listref of OPOSSUM::ConservedRegion objects.
 Args	  : Gene pair ID,
	    Conservation level,
	    OPTIONAL upstream BP,
	    OPTIONAL downstream BP

=cut

sub fetch_by_upstream_downstream
{
    my ($self, $gpid, $level, $upstream_bp, $downstream_bp) = @_;

    return $self->fetch_list_by_upstream_downstream(
    				$gpid, $level, $upstream_bp, $downstream_bp);
}

=head2 fetch_list_by_upstream_downstream

 Title    : fetch_list_by_upstream_downstream
 Usage    : $regions = $cra->fetch_list_by_upstream_downstream(
				$gpid, $cons_level, $upstream_bp,
				$downstream_bp);
 Function : Fetch the list of conserved regions for a given gene pair
 	    at the given level of conservation from the DB. Limit
	    the conserved regions to those which fall within
	    the specified amount of upstream/downstream bp of any
	    promoter (TSS) of the gene. If upstream/downstream bp are
	    not specified, conserved regions are limited to the boundaries
	    of the promoter regions.
 Returns  : A listref of OPOSSUM::ConservedRegion objects.
 Args	  : Gene pair ID,
	    Conservation level,
	    OPTIONAL upstream BP,
	    OPTIONAL downstream BP

=cut

sub fetch_list_by_upstream_downstream
{
    my ($self, $gpid, $level, $upstream_bp, $downstream_bp) = @_;

    if (!$gpid) {
        carp "must provide gene pair ID";
	return;
    }

    if (!$level) {
        carp "must provide conservation level";
	return;
    }

    my $gpa = $self->db->get_GenePairAdaptor;
    if (!$gpa) {
        carp "error getting GenePairAdaptor";
        return;
    }

    my $ppa = $self->db->get_PromoterPairAdaptor;
    if (!$ppa) {
        carp "error getting PromoterPairAdaptor";
        return;
    }

    my $gene_pair = $gpa->fetch_by_gene_pair_id($gpid);
    if (!$gene_pair) {
        carp "error fetching GenePair $gpid";
        return;
    }

    my $promoter_pairs = $ppa->fetch_by_gene_pair_id($gpid);
    if (!$promoter_pairs) {
        carp "no PromoterPairs found for GenePair ID $gpid";
        return;
    }

    my $strand = $gene_pair->strand1;

    #
    # We want to find all the conserved regions within the specified
    # upstream/downstream bp of all the promoters for the given gene
    # These promoter regions may overlap and we do not want to double
    # count so combine overlapping promoter regions into single search regions.
    #
    my @search_regions = _define_search_regions($promoter_pairs, $upstream_bp,
    				$downstream_bp, $strand);
    @search_regions = _combine_search_regions(@search_regions);

    #
    # A single conserved region could conceivably overlap more than one
    # search region. So change algorithm to select and truncate conserved
    # regions for each search region. DJA 2007/01/29
    #
    my $sql = qq{
		select start1,
			end1,
			start2,
			end2,
			rel_start1,
			rel_end1,
			rel_start2,
			rel_end2,
			conservation_level,
			conservation
		from conserved_regions
		where gene_pair_id = $gpid
		and conservation_level = $level
		and end1 >= ? and start1 <= ?
		order by start1
	    };

    my $sth = $self->prepare($sql);

    if (!$sth) {
	my $error = "ERROR preparing fetch conserved regions for GenePair $gpid"
			. " at conservation level $level; upstream/downstream"
			. " bp $upstream_bp/$downstream_bp";
	carp $error . "\n" . $self->errstr;
	return;
    }

    my @regions;
    foreach my $sr (@search_regions) {
	my $sr_start = $sr->start;
	my $sr_end = $sr->end;

	if (!$sth->execute($sr_start, $sr_end)) {
	    my $error = "ERROR executing fetch conserved regions for GenePair"
	    		. " $gpid at conservation level $level;"
			. " upstream/downstream bp $upstream_bp/$downstream_bp";
	    carp $error . "\n" . $self->errstr;
	    return;
	}

	while (my @row = $sth->fetchrow_array) {
	    my $region = OPOSSUM::ConservedRegion->new(
				    -gene_pair_id	=> $gpid,
				    -start1		=> $row[0],
				    -end1		=> $row[1],
				    -start2		=> $row[2],
				    -end2		=> $row[3],
				    -rel_start1		=> $row[4],
				    -rel_end1		=> $row[5],
				    -rel_start2		=> $row[6],
				    -rel_end2		=> $row[7],
				    -level		=> $row[8],
				    -conservation	=> $row[9]);

	    #
	    # Truncate edges of conserved regions at search region boundaries
	    #
	    # XXX NOTE we are not truncating the corresponding species 2 start
	    # and end's, nor are we truncating the relative start an ends. We
	    # really should do this. DO NOT use these other start/ends for
	    # computing conserved region lengths. XXX
	    #
	    if ($region->end1 >= $sr_start && $region->start1 <= $sr_end) {
		if ($region->start1 < $sr_start) {
		    $region->start1($sr_start);
		}
		if ($region->end1 > $sr_end) {
		    $region->end1($sr_end);
		}
	    }
	    
	    push @regions, $region;
	}
    }

    return @regions ? \@regions : undef;
}

=head2 fetch_set_by_upstream_downstream

 Title    : fetch_set_by_upstream_downstream
 Usage    : $regions = $cra->fetch_set_by_upstream_downstream(
				$gpid, $cons_level, $upstream_bp,
				$downstream_bp);
 Function : Fetch the set of conserved regions for a given gene pair
 	    at the given level of conservation from the DB. Limit
	    the conserved regions to those which fall within
	    the specified amount of upstream/downstream bp of any
	    promoter (TSS) of the gene. If upstream/downstream bp are
	    not specified, conserved regions are limited to the boundaries
	    of the promoter regions.
 Returns  : An OPOSSUM::ConservedRegionSet object.
 Args	  : Gene pair ID,
	    Conservation level,
	    OPTIONAL upstream BP,
	    OPTIONAL downstream BP

=cut

sub fetch_set_by_upstream_downstream
{
    my ($self, $gpid, $level, $upstream_bp, $downstream_bp) = @_;

    if (!$gpid) {
        carp "must provide gene pair ID";
	return;
    }

    if (!$level) {
        carp "must provide conservation level";
	return;
    }

    my $gpa = $self->db->get_GenePairAdaptor;
    if (!$gpa) {
        carp "error getting GenePairAdaptor";
        return;
    }

    my $ppa = $self->db->get_PromoterPairAdaptor;
    if (!$ppa) {
        carp "error getting PromoterPairAdaptor";
        return;
    }

    my $gene_pair = $gpa->fetch_by_gene_pair_id($gpid);
    if (!$gene_pair) {
        carp "error fetching GenePair $gpid";
        return;
    }

    my $promoter_pairs = $ppa->fetch_by_gene_pair_id($gpid);
    if (!$promoter_pairs) {
        carp "no PromoterPairs found for GenePair ID $gpid";
        return;
    }

    my $strand = $gene_pair->strand1;

    #
    # We want to find all the conserved regions within the specified
    # upstream/downstream bp of all the promoters for the given gene
    # These promoter regions may overlap and we do not want to double
    # count so combine overlapping promoter regions into single search regions.
    #
    my @search_regions = _define_search_regions($promoter_pairs, $upstream_bp,
    				$downstream_bp, $strand);
    @search_regions = _combine_search_regions(@search_regions);

    #
    # A single conserved region could conceivably overlap more than one
    # search region. So change algorithm to select and truncate conserved
    # regions for each search region. DJA 2007/01/29
    #
    my $sql = qq{
		select start1,
			end1,
			start2,
			end2,
			rel_start1,
			rel_end1,
			rel_start2,
			rel_end2,
			conservation_level,
			conservation
		from conserved_regions
		where gene_pair_id = $gpid
		and conservation_level = $level
		and end1 >= ? and start1 <= ?
		order by start1
	    };

    my $sth = $self->prepare($sql);

    if (!$sth) {
	my $error = "ERROR preparing fetch conserved regions for GenePair $gpid"
			. " at conservation level $level; upstream/downstream"
			. " bp $upstream_bp/$downstream_bp";
	carp $error . "\n" . $self->errstr;
	return;
    }

    my $cr_set = OPOSSUM::ConservedRegionSet->new;
    $cr_set->param('gene_pair_id', $gpid);
    $cr_set->param('conservation_level', $level);

    foreach my $sr (@search_regions) {
	my $sr_start = $sr->start;
	my $sr_end = $sr->end;

	if (!$sth->execute($sr_start, $sr_end)) {
	    my $error = "ERROR executing fetch conserved regions for GenePair"
	    		. " $gpid at conservation level $level;"
			. " upstream/downstream bp $upstream_bp/$downstream_bp";
	    carp $error . "\n" . $self->errstr;
	    return;
	}

	while (my @row = $sth->fetchrow_array) {
	    my $region = OPOSSUM::ConservedRegion->new(
				    -gene_pair_id	=> $gpid,
				    -start1		=> $row[0],
				    -end1		=> $row[1],
				    -start2		=> $row[2],
				    -end2		=> $row[3],
				    -rel_start1		=> $row[4],
				    -rel_end1		=> $row[5],
				    -rel_start2		=> $row[6],
				    -rel_end2		=> $row[7],
				    -level		=> $row[8],
				    -conservation	=> $row[9]);

	    #
	    # Truncate edges of conserved regions at search region boundaries
	    #
	    # XXX NOTE we are not truncating the corresponding species 2 start
	    # and end's, nor are we truncating the relative start an ends. We
	    # really should do this. DO NOT use these other start/ends for
	    # computing conserved region lengths. XXX
	    #
	    if ($region->end1 >= $sr_start && $region->start1 <= $sr_end) {
		if ($region->start1 < $sr_start) {
		    $region->start1($sr_start);
		}
		if ($region->end1 > $sr_end) {
		    $region->end1($sr_end);
		}
	    }
	    
	    $cr_set->add_conserved_region($region);
	}
    }

    return $cr_set;
}

=head2 fetch_length_by_gene_pair_id

 Title    : fetch_length_by_gene_pair_id
 Usage    : $len = $cra->fetch_length_by_gene_pair_id($gpid, $level);
 Function : Fetch the total length of the conserved regions for a
 	    given gene pair at the given level of conservation.
 Returns  : An integer length.
 Args	  : Integer gene pair ID and integer conservation level.

=cut

sub fetch_length_by_gene_pair_id
{
    my ($self, $gpid, $level) = @_;

    return if !$gpid;

    $level = 1 if !$level;

    my $sql = qq{
		    select sum(end1 - start1 + 1)
		    from conserved_regions
		    where gene_pair_id = $gpid
		    and conservation_level = $level
		};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "ERROR preparing fetch conserved regions length for GenePair $gpid"
		. " at conservation level $level" . "\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "ERROR executing fetch conserved regions length for GenePair $gpid"
		. " at conservation level $level" . "\n" . $self->errstr;
	return;
    }

    my $length = 0;
    if (my @row = $sth->fetchrow_array) {
    	$length = $row[0];
    }

    return $length;
}

# New method added by DJA on 2007/01/29

=head2 fetch_length_by_upstream_downstream

 Title    : fetch_length_by_upstream_downstream
 Usage    : $length = $cra->fetch_length_by_upstream_downstream(
				$gpid, $cons_level, $upstream_bp,
				$downstream_bp);
 Function : Fetch the length of conserved regions for a given gene pair
 	    at the given level of conservation from the DB. Limit
	    the conserved regions to those which fall within
	    the specified amount of upstream/downstream bp of any
	    promoter (TSS) of the gene. If upstream/downstream bp are
	    not specified, conserved regions are limited to the boundaries
	    of the promoter regions.
 Returns  : The total length of the conserved regions.
 Args	  : Gene pair ID,
	    Conservation level,
	    OPTIONAL upstream BP,
	    OPTIONAL downstream BP

=cut

sub fetch_length_by_upstream_downstream
{
    my ($self, $gpid, $level, $upstream_bp, $downstream_bp) = @_;

    if (!$gpid) {
        carp "must provide gene pair ID";
	return;
    }

    if (!$level) {
        carp "must provide conservation level";
	return;
    }

    my $gpa = $self->db->get_GenePairAdaptor;
    if (!$gpa) {
        carp "error getting GenePairAdaptor";
        return;
    }

    my $ppa = $self->db->get_PromoterPairAdaptor;
    if (!$ppa) {
        carp "error getting PromoterPairAdaptor";
        return;
    }

    my $gene_pair = $gpa->fetch_by_gene_pair_id($gpid);
    if (!$gene_pair) {
        carp "error fetching GenePair $gpid";
        return;
    }

    my $promoter_pairs = $ppa->fetch_by_gene_pair_id($gpid);
    if (!$promoter_pairs) {
        carp "no PromoterPairs found for GenePair ID $gpid";
        return;
    }

    my $strand = $gene_pair->strand1;

    #
    # We want to find all the conserved regions within the specified
    # upstream/downstream bp of all the promoters for the given gene
    # These promoter regions may overlap and we do not want to double
    # count so combine overlapping promoter regions into single search regions.
    #
    my @search_regions = _define_search_regions($promoter_pairs, $upstream_bp,
    				$downstream_bp, $strand);
    @search_regions = _combine_search_regions(@search_regions);

    my $sql = qq{
		    select sum((if (end1 > ?, ?, end1)
				    - if (start1 < ?, ?, start1)) + 1)
		    from conserved_regions
		    where gene_pair_id = $gpid
		    and conservation_level = $level
		    and end1 >= ? and start1 <= ?
		};

    my $sth = $self->prepare($sql);

    if (!$sth) {
	my $error = "ERROR preparing fetch conserved region length for"
			. " GenePair $gpid at conservation level $level;"
			. " upstream/downstream bp $upstream_bp/$downstream_bp";
	carp $error . "\n" . $self->errstr;
	return;
    }

    my $length = 0;
    foreach my $sr (@search_regions) {
	my $sr_start = $sr->start;
	my $sr_end = $sr->end;

	if (!$sth->execute($sr_end, $sr_end, $sr_start, $sr_start, $sr_start,
				$sr_end))
	{
	    my $error = "ERROR executing fetch conserved regions length for"
	    		. " GenePair $gpid at conservation level $level;"
			. " upstream/downstream bp $upstream_bp/$downstream_bp";
	    carp $error . "\n" . $self->errstr;
	    return;
	}

	my @row = $sth->fetchrow_array;
	if (@row && $row[0]) {
	    $length += $row[0];
	}
    }

    return $length;
}

=head2 store

 Title   : store
 Usage   : $cra->store($region);
 Function: Store a single ConservedRegion object in the database.
 Args    : An OPOSSUM::ConservedRegion object
 Returns : True on success, false otherwise.

=cut

sub store
{
    my ($self, $cr) = @_;

    return if !$cr;

    if (!$cr->isa('OPOSSUM::ConservedRegion')) {
    	carp "Not an OPOSSUM::ConservedRegion object";
	return;
    }

    my $sql = qq{insert into conserved_regions (
		    gene_pair_id, start1, end1, start2, end2, rel_start1,
		    rel_end1, rel_start2, rel_end2, conservation_level,
		    conservation)
		values (?,?,?,?,?,?,?,?,?,?,?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert conserved regions statement - "
		. $self->errstr;
	return;
    }

    if (!$sth->execute(
		$cr->gene_pair_id, $cr->start1, $cr->end1, $cr->start2,
		$cr->end2, $cr->rel_start1, $cr->rel_end1, $cr->rel_start2,
		$cr->rel_end2, $cr->level, $cr->conservation))
    {
	carp "Error inserting OPOSSUM::ConservedRegion - " . $sth->errstr;
	return;
    }

    return 1;
}

=head2 store_list

 Title   : store_list
 Usage   : $cra->store_list($regions, $gene_pair_id, $level);
 Function: Store a list of conserved regions in the database.
 Args    : The list of conserved regions to store (ref to a list of
	   either Bio::SeqFeature::FeaturePair objects or a
	   OPOSSUM::ConservedRegion objects);
	   The ID of the GenePair with which this conserved region
	   list is associated;
	   The conservation level of these conserved regions.
 Returns : True on success, false otherwise.

=cut

sub store_list
{
    my ($self, $regions, $gpid, $level) = @_;

    return if !$regions || !$regions->[0];

    if (!$regions->[0]->isa('Bio::SeqFeature::FeaturePair') &&
	    !$regions->[0]->isa('OPOSSUM::ConservedRegion'))
    {
    	carp "Not a Bio::SeqFeature::FeaturePair or OPOSSUM::ConservedRegion"
		. " list";
	return;
    }

    my $sql = qq{insert into conserved_regions (
		    gene_pair_id, start1, end1, start2, end2, rel_start1,
		    rel_end1, rel_start2, rel_end2, conservation_level,
		    conservation)
		values (?,?,?,?,?,?,?,?,?,?,?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert conserved regions statement - "
		. $self->errstr;
	return;
    }

    my $ok = 1;
    foreach my $cr (@$regions) {
	if ($cr->isa('Bio::SeqFeature::FeaturePair')) {
	    if (!$sth->execute(
	    		$gpid, $cr->start, $cr->end, $cr->hstart, $cr->hend,
			undef, undef, undef, undef, $level, $cr->score))
	    {
		carp "Error inserting Bio::SeqFeature::FeaturePair - "
			. $sth->errstr;
		$ok = 0;
	    }
	} elsif ($cr->isa('OPOSSUM::ConservedRegion')) {
	    if (!$sth->execute(
	    		$gpid, $cr->start1, $cr->end1, $cr->start2, $cr->end2,
			$cr->rel_start1, $cr->rel_end1, $cr->rel_start2,
			$cr->rel_end2, $level, $cr->conservation))
	    {
		carp "Error inserting OPOSSUM::ConservedRegion - "
			. $sth->errstr;
		$ok = 0;
	    }
	} else {
	    carp "Not a Bio::SeqFeature::FeaturePair or "
	    	. " OPOSSUM::ConservedRegion object";
	    return;
	}
    }

    return $ok;
}

=head2 store_set

 Title   : store_set
 Usage   : $cra->store_set($cr_set);
 Function: Store a set of conserved regions in the database.
 Args    : An OPOSSUM::ConservedRegionSet object
 Returns : True on success, false otherwise.

=cut

sub store_set
{
    my ($self, $cr_set) = @_;

    return if !$cr_set;

    if (!$cr_set->isa('OPOSSUM::ConservedRegionSet')) {
    	carp "Not an OPOSSUM::ConservedRegionSet";
	return;
    }

    my $level = $cr_set->param('conservation_level');
    if (!$level) {
    	carp "OPOSSUM::ConservedRegionSet conservation_level parameter not set";
	return;
    }

    my $gpid = $cr_set->param('gene_pair_id');
    if (!$gpid) {
    	carp "OPOSSUM::ConservedRegionSet gene_pair_id parameter not set";
	return;
    }

    my $sql = qq{insert into conserved_regions (
		    gene_pair_id, start1, end1, start2, end2, rel_start1,
		    rel_end1, rel_start2, rel_end2, conservation_level,
		    conservation)
		values (?,?,?,?,?,?,?,?,?,?,?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert conserved regions statement - "
		. $self->errstr;
	return;
    }

    my $ok = 1;
    foreach my $cr (@{$cr_set->conserved_regions}) {
	if (!$sth->execute(
		    $gpid, $cr->start1, $cr->end1, $cr->start2, $cr->end2,
		    $cr->rel_start1, $cr->rel_end1, $cr->rel_start2,
		    $cr->rel_end2, $level, $cr->conservation))
	{
	    carp "Error inserting OPOSSUM::ConservedRegion - "
		    . $sth->errstr;
	    $ok = 0;
	}
    }

    return $ok;
}

sub _define_search_regions
{
    my ($promoter_pairs, $upstream_bp, $downstream_bp, $strand) = @_;

    my @search_regions;
    foreach my $pp (@$promoter_pairs) {
	my $pp_tss1 = $pp->tss1;
	my $pp_start1 = $pp->start1;
	my $pp_end1 = $pp->end1;

	my $tss_start;
	my $tss_end;
	if ($strand == 1) {
	    if (defined $upstream_bp) {
		$tss_start = $pp_tss1 - $upstream_bp;
		$tss_start = $pp_start1 if $pp_start1 > $tss_start;
	    } else {
		$tss_start = $pp_start1;
	    }

	    if (defined $downstream_bp) {
		$tss_end = $pp_tss1 + $downstream_bp - 1;
		$tss_end = $pp_end1 if $pp_end1 < $tss_end;
	    } else {
		$tss_end = $pp_end1;
	    }
	} elsif ($strand == -1) {
	    if (defined $upstream_bp) {
		$tss_end = $pp_tss1 + $upstream_bp;
		$tss_end = $pp_end1 if $pp_end1 < $tss_end;
	    } else {
		$tss_end = $pp_end1;
	    }

	    if (defined $downstream_bp) {
		$tss_start = $pp_tss1 - $downstream_bp + 1;
		$tss_start = $pp_start1 if $pp_start1 > $tss_start;
	    } else {
		$tss_start = $pp_start1;
	    }
	} else {
	    carp "error determining promoter pair strand";
	    return;
	}

	push @search_regions, Bio::SeqFeature::Generic->new(
					-start	=> $tss_start,
					-end	=> $tss_end);
    }

    return @search_regions;
}

sub _combine_search_regions
{
    my (@regs) = @_;

    return if !@regs;

    @regs = sort {$a->start <=> $b->start} @regs;

    my $num_regs = scalar @regs;
    for (my $i = 0; $i < $num_regs; $i++) {
	my $reg1 = $regs[$i] if exists($regs[$i]);
	if ($reg1) {
	    for (my $j = $i+1; $j < $num_regs; $j++) {
		my $reg2 = $regs[$j] if exists ($regs[$j]);
		if ($reg2) {
		    if (_feature_combine($reg1, $reg2)) {
			if ($reg2->start < $reg1->start) {
			    $reg1->start($reg2->start);
			}

			if ($reg2->end > $reg1->end) {
			    $reg1->end($reg2->end);
			}
			delete $regs[$j];
		    } else {
			last;
		    }
		}
	    }
	}
    }

    my @unique_regs;
    foreach my $reg (@regs) {
	if (defined $reg) {
	    push @unique_regs, $reg;
	}
    }

    return @unique_regs;
}

sub _feature_combine
{
    my ($feat1, $feat2) = @_;

    my $combine = 1;
    $combine = 0 if $feat1->start > $feat2->end + 1
			|| $feat1->end < $feat2->start - 1;

    return $combine;
}

1;
