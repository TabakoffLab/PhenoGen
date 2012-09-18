=head1 NAME

OPOSSUM::DBSQL::PromoterPairAdaptor - Adaptor for MySQL queries to retrieve
and store PromoterPair objects.

=head1 SYNOPSIS

$ppa = $db_adaptor->get_PromoterPairAdaptor();

=head1 DESCRIPTION

The promoter_pairs table contains records which store promoter information
for the associated gene pair. Currently there is a one-to-one mapping of
gene pairs to promoter pairs although in theory there could be multiple
promoters for a given gene. This table stores the various chromosomal coordinate
information which was used to retrieve sequences, align them and scan for TFBSs.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::DBSQL::PromoterPairAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::PromoterPair;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_promoter_pair_ids

 Title    : fetch_promoter_pair_ids
 Usage    : $ids = $ppa->fetch_promoter_pair_ids($where_clause);
 Function : Fetch a list of all the promoter pair IDs, optionally using
 	    a where clause.
 Returns  : A list ref of integer promoter pair IDs.
 Args	  : Optionally an SQL where clause.

=cut

sub fetch_promoter_pair_ids
{
    my ($self, $where_clause) = @_;

    my $sql = "select promoter_pair_id from promoter_pairs";
    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching promoter pair IDs\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching promoter pair IDs\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($id) = $sth->fetchrow_array) {
    	push @ids, $id;
    }
    $sth->finish;

    return @ids ? \@ids : undef;
}

=head2 fetch_gene_pair_ids

 Title    : fetch_gene_pair_ids
 Usage    : $ids = $ppa->fetch_gene_pair_ids($where_clause);
 Function : Fetch a list of all the gene pair IDs in the database which
 	    have associated promoter pairs, optionally using a where clause.
 Returns  : A list ref of integer gene pair IDs.
 Args	  : Optionally an SQL where clause.

=cut

sub fetch_gene_pair_ids
{
    my ($self, $where_clause) = @_;

    my $sql = "select distinct gene_pair_id from promoter_pairs";
    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair IDs\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching gene pair IDs\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($id) = $sth->fetchrow_array) {
    	push @ids, $id;
    }
    $sth->finish;

    return @ids ? \@ids : undef;
}

#=head2 fetch_alignment_ids
#
# Title    : fetch_alignment_ids
# Usage    : $ids = $ppa->fetch_alignment_ids($where_clause);
# Function : Fetch a list of all the alignment IDs in the database which
# 	    have associated promoter pairs, optionally using a where clause.
# Returns  : A list ref of integer alignment IDs.
# Args	  : Optionally an SQL where clause.
#
#=cut
#
#sub fetch_alignment_ids
#{
#    my ($self, $where_clause) = @_;
#
#    my $sql = "select distinct alignment_id from promoter_pairs";
#    if ($where_clause) {
#    	$sql .= " where $where_clause";
#    }
#
#    my $sth = $self->prepare($sql);
#    if (!$sth) {
#	carp "error fetching alignment IDs\n" . $self->errstr;
#	return;
#    }
#
#    if (!$sth->execute) {
#	carp "error fetching alignment IDs\n" . $self->errstr;
#	return;
#    }
#
#    my @ids;
#    while (my ($id) = $sth->fetchrow_array) {
#    	push @ids, $id;
#    }
#    $sth->finish;
#
#    return @ids ? \@ids : undef;
#}

=head2 fetch_gene_pair_id_fields

 Title    : fetch_gene_pair_id_fields
 Usage    : $ids = $ppa->fetch_gene_pair_id_fields($id_field);
 Function : Fetch a list of all $id_field column values of the gene pairs
 	    which have associated promoter pairs.
 Returns  : A list ref of gene pair $id_field column values.
 Args	  : None.

=cut

sub fetch_gene_pair_id_fields
{
    my ($self, $id_field) = @_;

    if (!$id_field) {
    	return $self->fetch_gene_pair_ids;
    }

    my $sql = qq{select distinct g.$id_field
		from gene_pairs g, promoter_pairs p
		where g.gene_pair_id = p.gene_pair_id};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair $id_field fields\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching gene pair $id_field fields\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($id) = $sth->fetchrow_array) {
    	push @ids, $id;
    }
    $sth->finish;

    return @ids ? \@ids : undef;
}

=head2 fetch_by_promoter_pair_id

 Title    : fetch_by_promoter_pair_id
 Usage    : $pp = $ppa->fetch_by_promoter_pair_id($id);
 Function : Fetch a promoter pair by it's promoter pair ID.
 Returns  : An OPOSSUM::PromoterPair object.
 Args	  : An integer promoter pair ID.

=cut

sub fetch_by_promoter_pair_id
{
    my ($self, $promoter_pair_id) = @_;

    my $sql = qq{select promoter_pair_id,
    			gene_pair_id,
			primary_promoter,
			chr1,
			start1,
			end1,
			tss1,
		        strand1,
			rel_start1,
			rel_end1,
			rel_tss1,
			ensembl_transcript_id1,
			cage_evidence1,
			chr2,
			start2,
			end2,
			tss2,
                        strand2,
			rel_start2,
			rel_end2,
			rel_tss2,
			ensembl_transcript_id2,
			cage_evidence2
		from promoter_pairs
		where promoter_pair_id = $promoter_pair_id
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching promoter pair with promoter_pair_id ="
		. " $promoter_pair_id\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching promoter pair with promoter_pair_id ="
		. " $promoter_pair_id\n" . $self->errstr;
	return;
    }

    my $promoter_pair;
    if (my @row = $sth->fetchrow_array) {
	$promoter_pair = OPOSSUM::PromoterPair->new(
				-id			=> $row[0],
				-gene_pair_id		=> $row[1],
				-primary_promoter	=> $row[2],
				-chr1			=> $row[3],
				-start1			=> $row[4],
				-end1			=> $row[5],
				-tss1			=> $row[6],
				-strand1                => $row[7],
				-rel_start1		=> $row[8],
				-rel_end1		=> $row[9],
				-rel_tss1		=> $row[10],
				-ensembl_transcript_id1	=> $row[11],
				-cage_evidence1		=> $row[12],
				-chr2			=> $row[13],
				-start2			=> $row[14],
				-end2			=> $row[15],
				-tss2			=> $row[16],
                                -strand2                => $row[17],
				-rel_start2		=> $row[18],
				-rel_end2		=> $row[19],
				-rel_tss2		=> $row[20],
				-ensembl_transcript_id2	=> $row[21],
				-cage_evidence2		=> $row[22]);
    }
    $sth->finish;

    return $promoter_pair;
}

=head2 fetch_by_gene_pair_id

 Title    : fetch_by_gene_pair_id
 Usage    : $pps = $ppa->fetch_by_gene_pair_id($id);
 Function : Fetch promoter pairs by their associated gene pair ID.
 Returns  : A list ref of OPOSSUM::PromoterPair objects.
 Args	  : A gene pair ID.

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $gene_pair_id) = @_;

    my $sql = qq{select promoter_pair_id,
    			gene_pair_id,
			primary_promoter,
			chr1,
			start1,
			end1,
			tss1,
		        strand1,
			rel_start1,
			rel_end1,
			rel_tss1,
			ensembl_transcript_id1,
			cage_evidence1,
			chr2,
			start2,
			end2,
			tss2,
		        strand2,
			rel_start2,
			rel_end2,
			rel_tss2,
			ensembl_transcript_id2,
			cage_evidence2
		from promoter_pairs
		where gene_pair_id = $gene_pair_id
		order by start1
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching promoter pairs with gene_pair_id ="
		. " $gene_pair_id\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching promoter pairs with gene_pair_id ="
		. " $gene_pair_id\n" . $self->errstr;
	return;
    }

    my @promoter_pairs;
    while (my @row = $sth->fetchrow_array) {
	push @promoter_pairs, OPOSSUM::PromoterPair->new(
				-id			=> $row[0],
				-gene_pair_id		=> $row[1],
				-primary_promoter	=> $row[2],
				-chr1			=> $row[3],
				-start1			=> $row[4],
				-end1			=> $row[5],
				-tss1			=> $row[6],
				-strand1                => $row[7],
				-rel_start1		=> $row[8],
				-rel_end1		=> $row[9],
				-rel_tss1		=> $row[10],
				-ensembl_transcript_id1	=> $row[11],
				-cage_evidence1		=> $row[12],
				-chr2			=> $row[13],
				-start2			=> $row[14],
				-end2			=> $row[15],
				-tss2			=> $row[16],
				-strand2                => $row[17],
				-rel_start2		=> $row[18],
				-rel_end2		=> $row[19],
				-rel_tss2		=> $row[20],
				-ensembl_transcript_id2	=> $row[21],
				-cage_evidence2		=> $row[22]);
    }

    return @promoter_pairs ? \@promoter_pairs : undef;
}

=head2 fetch_primary_by_gene_pair_id

 Title    : fetch_primary_by_gene_pair_id
 Usage    : $pp = $ppa->fetch_primary_by_gene_pair_id($id);
 Function : Fetch the primary promoter pair of a given gene pair by the
 	    gene pair ID.
 Returns  : An OPOSSUM::PromoterPair object.
 Args	  : A gene pair ID.

=cut

sub fetch_primary_by_gene_pair_id
{
    my ($self, $gene_pair_id) = @_;

    my $sql = qq{select promoter_pair_id,
    			gene_pair_id,
			primary_promoter,
			chr1,
			start1,
			end1,
			tss1,
                        strand1,
			rel_start1,
			rel_end1,
			rel_tss1,
			ensembl_transcript_id1,
			cage_evidence1,
			chr2,
			start2,
			end2,
			tss2,
		        strand2,
			rel_start2,
			rel_end2,
			rel_tss2,
			ensembl_transcript_id2,
			cage_evidence2
		from promoter_pairs
		where gene_pair_id = $gene_pair_id
		and primary_promoter = TRUE
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching primary promoter pair for gene_pair_id ="
		. " $gene_pair_id\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching primary promoter pair for gene_pair_id ="
		. " $gene_pair_id\n" . $self->errstr;
	return;
    }

    my $promoter_pair;
    if (my @row = $sth->fetchrow_array) {
	$promoter_pair = OPOSSUM::PromoterPair->new(
				-id			=> $row[0],
				-gene_pair_id		=> $row[1],
				-primary_promoter	=> $row[2],
				-chr1			=> $row[3],
				-start1			=> $row[4],
				-end1			=> $row[5],
				-tss1			=> $row[6],
				-strand1                => $row[7],
				-rel_start1		=> $row[8],
				-rel_end1		=> $row[9],
				-rel_tss1		=> $row[10],
				-ensembl_transcript_id1	=> $row[11],
				-cage_evidence1		=> $row[12],
				-chr2			=> $row[13],
				-start2			=> $row[14],
				-end2			=> $row[15],
				-tss2			=> $row[16],
                                -strand2                => $row[17],
				-rel_start2		=> $row[18],
				-rel_end2		=> $row[19],
				-rel_tss2		=> $row[20],
				-ensembl_transcript_id2	=> $row[21],
				-cage_evidence2		=> $row[22]);
    }
    $sth->finish;

    return $promoter_pair;
}

=head2 store

 Title   : store
 Usage   : $id = $ppa->store($promoter_pair);
 Function: Store promoter pair in the database.
 Args    : The promoter pair (OPOSSUM::PromoterPair) to store.
 Returns : A database ID of the newly stored promoter pair.

=cut

sub store
{
    my ($self, $promoter_pair) = @_;

    if (!ref $promoter_pair || !$promoter_pair->isa('OPOSSUM::PromoterPair')) {
    	carp "Not an OPOSSUM::PromoterPair object";
	return;
    }

    my $sql = qq{insert into promoter_pairs (
		    gene_pair_id,
		    primary_promoter,
		    chr1,
		    chr2,
		    start1,
		    start2,
		    end1,
		    end2,
		    tss1,
		    tss2,
                    strand1,
                    strand2,
		    rel_start1,
		    rel_start2,
		    rel_end1,
		    rel_end2,
		    rel_tss1,
		    rel_tss2,
		    cage_evidence1,
		    cage_evidence2,
		    ensembl_transcript_id1,
		    ensembl_transcript_id2)
		values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert promoter pair statement\n" . $self->errstr;
	return;
    }

    if (!$sth->execute( $promoter_pair->gene_pair_id,
    			$promoter_pair->primary_promoter,
    			$promoter_pair->chr1,
    			$promoter_pair->chr2,
    			$promoter_pair->start1,
    			$promoter_pair->start2,
    			$promoter_pair->end1,
    			$promoter_pair->end2,
    			$promoter_pair->tss1,
    			$promoter_pair->tss2,
			$promoter_pair->strand1,
			$promoter_pair->strand2,
    			$promoter_pair->rel_start1,
    			$promoter_pair->rel_start2,
    			$promoter_pair->rel_end1,
    			$promoter_pair->rel_end2,
    			$promoter_pair->rel_tss1,
    			$promoter_pair->rel_tss2,
			$promoter_pair->cage_evidence1,
			$promoter_pair->cage_evidence2,
			$promoter_pair->ensembl_transcript_id1,
			$promoter_pair->ensembl_transcript_id2))
    {
    	carp "Error inserting promoter pair\n" . $self->errstr;
	return;
    }

    return $sth->{'mysql_insertid'};
}

1;
