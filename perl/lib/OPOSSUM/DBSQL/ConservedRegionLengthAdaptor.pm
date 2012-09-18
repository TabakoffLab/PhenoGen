=head1 NAME

OPOSSUM::DBSQL::ConservedRegionLengthAdaptor - Adaptor for MySQL queries to
retrieve and store conserved region lengths.

=head1 SYNOPSIS

$cra = $db_adaptor->get_ConservedRegionLengthAdaptor();

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

Modified by Shannan Ho Sui on Dec 29, 2006

=head1 METHODS

=cut
package OPOSSUM::DBSQL::ConservedRegionLengthAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::ConservedRegionLengthSet;
use OPOSSUM::ConservedRegionLength;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

=head2 new

 Title    : new
 Usage    : $crla = OPOSSUM::DBSQL::ConservedRegionLengthAdaptor->new(@args);
 Function : Create a new ConservedRegionLengthAdaptor.
 Returns  : A new OPOSSUM::DBSQL::ConservedRegionLengthAdaptor object.
 Args	  : An OPOSSUM::DBSQL::DBConnection object.

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_promoter_pair_ids

 Title    : fetch_gene_pair_ids
 Usage    : $ids = $crla->fetch_gene_pair_ids();
 Function : Fetch a list of all the gene pair IDs for the conserved
 	    region lengths in the current DB.
 Returns  : A reference to a list of gene pair IDs.
 Args	  : None.

=cut

sub fetch_gene_pair_ids
{
    my ($self) = @_;

    my $sql = qq{select distinct gene_pair_id
    		from conserved_region_lengths};

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

    return @ids ? \@ids : undef;
}

=head2 fetch_lengths

 Title    : fetch_lengths
 Usage    : $lengths = $crla->fetch_lengths(
 				-gene_pair_ids	=> $gpids,
				-conservation_level	=> $clevel,
				-search_region_level	=> $srlevel);
 Function : Fetch a list of the lengths for all the conserved region
 	    length records for the given list of gene pair IDs at
	    the given level of conservation and search region level.
 Returns  : A reference to a list of integer lengths.
 Args	  : Optional list ref of gene pair IDS;
 	    optional integer conservation level;
	    optional integer search region level.

=cut

sub fetch_lengths
{
    my ($self, %args) = @_;

    my $gpids = $args{-gene_pair_ids};
    my $cons_level = $args{-conservation_level};
    my $sr_level = $args{-search_region_level};

    my $sql = qq{
		select gene_pair_id, conservation_level,
			search_region_level, length
		from conserved_region_lengths
	    };

    my $where = "where";
    if (defined $cons_level) {
    	$sql .= " $where conservation_level = $cons_level";
	$where = "and";
    }

    if (defined $sr_level) {
	$sql .= " $where search_region_level = $sr_level";
	$where = "and";
    }

    if ($gpids && $gpids->[0]) {
	$sql .= " $where gene_pair_id in (";
	$sql .= join(',', @$gpids);
        $sql .= ")";
    }

    $sql .= " order by gene_pair_id";

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching conserved region lengths with\n$sql\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching conserved region lengths with\n$sql\n"
		. $self->errstr;
	return;
    }

    my @lengths;
    while (my @row = $sth->fetchrow_array) {
	push @lengths, OPOSSUM::ConservedRegionLength->new(
				-gene_pair_id	=> $row[0],
				-conservation_level	=> $row[1],
				-search_region_level	=> $row[2],
				-length			=> $row[3]);
    }
    $sth->finish;

    return @lengths ? \@lengths : undef;
}

=head2 fetch_length_set

 Title    : fetch_length_set
 Usage    : $len_set = $crla->fetch_length_set(
 				-gene_pair_ids	=> $gpids,
				-conservation_level	=> $clevel,
				-search_region_level	=> $srlevel);
 Function : Fetch the set of conserved region lengths for the given list
	    of gene pair IDs at the given level of conservation and
	    search region level.
 Returns  : An OPOSSUM::ConservedRegionLengthSet.
 Args	  : Optional list ref of gene pair IDS;
 	    optional integer conservation level;
	    optional integer search region level.

=cut

sub fetch_length_set
{
    my ($self, %args) = @_;

    my $cons_level = $args{-conservation_level};
    my $sr_level = $args{-search_region_level};
    if (!$cons_level || !$sr_level) {
    	carp "must provide conservation level and search region level\n";
	return;
    }

    my $gpids = $args{-gene_pair_ids};

    my $sql = qq{
		select gene_pair_id, conservation_level,
			search_region_level, length
		from conserved_region_lengths
		where conservation_level = $cons_level
		and search_region_level = $sr_level
	    };

    if ($gpids && $gpids->[0]) {
	$sql .= " and gene_pair_id in (";
	$sql .= join(',', @$gpids);
        $sql .= ")";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching conserved region lengths with\n$sql\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching conserved region lengths with\n$sql\n"
		. $self->errstr;
	return;
    }

    my $lengths = OPOSSUM::ConservedRegionLengthSet->new();
    while (my @row = $sth->fetchrow_array) {
	$lengths->add_conserved_region_length(
		    OPOSSUM::ConservedRegionLength->new(
				-gene_pair_id	=> $row[0],
				-conservation_level	=> $row[1],
				-search_region_level	=> $row[2],
				-length			=> $row[3]));
    }
    $sth->finish;

    $lengths->param('conservation_level', $cons_level);
    $lengths->param('search_region_level', $sr_level);

    return $lengths;
}

=head2 store

 Title    : store
 Usage    : $crla->store($crl);
 Function : Store a ConservedRegionLength object in the DB.
 Returns  : True on success, false otherwise.
 Args	  : An OPOSSUM::ConservedRegionLength

=cut

sub store
{
    my ($self, $crl) = @_;

    my $sql = qq{insert into conserved_region_lengths
		    (gene_pair_id, conservation_level, search_region_level,
		     length)
		values (?, ?, ?, ?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert conserved_region_lengths statement\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute($crl->gene_pair_id, $crl->conservation_level,
    			$crl->search_region_level, $crl->length))
    {
	carp sprintf("Error inserting conserved region length for GenePair ID"
		    . " %d " . $self->errstr,
		    $crl->gene_pair_id);
	return 0;
    }

    return 1;
}

1;
