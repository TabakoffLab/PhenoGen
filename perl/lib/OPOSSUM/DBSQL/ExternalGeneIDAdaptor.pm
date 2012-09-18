=head1 NAME

OPOSSUM::DBSQL::ExternalGeneIDAdaptor - Adaptor for MySQL queries to retrieve
and store external gene IDs.

=head1 SYNOPSIS

$xgia = $db_adaptor->get_ExternalGeneIDAdaptor();

=head1 DESCRIPTION

The external_gene_ids table contains records which map gene pairs contained in
the gene_pairs table with their corresponding external gene ids of various
types such as HUGO, accession number etc. NOTE that there may be a one-to-many
relationship between gene pair IDs and external gene IDs.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::ExternalGeneIDAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::ExternalGeneID;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

=head2 new

 Title    : new
 Usage    : $xgia = OPOSSUM::DBSQL::ExternalGeneIDAdaptor->new(@args);
 Function : Create a new ExternalGeneIDAdaptor.
 Returns  : A new OPOSSUM::DBSQL::ExternalGeneIDAdaptor object.
 Args	  : An OPOSSUM::DBSQL::DBConnection object.

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_gene_pair_ids

 Title    : fetch_gene_pair_ids
 Usage    : $ids = $xgia->fetch_gene_pair_ids($id_type, $species);
 Function : Fetch a list of all the distinct gene pair IDs for the
 	    external gene IDs in the database.
 Returns  : A list ref of integer gene pair IDs.
 Args	  : Optionally an integer ID type;
 	    optionally an integer species number.

=cut

sub fetch_gene_pair_ids
{
    my ($self, $id_type, $species) = @_;

    my $sql = qq{select distinct(gene_pair_id) from external_gene_ids};

    my $where = "where";
    if ($id_type) {
    	$sql .= " $where id_type = $id_type";
	$where = "and";
    }

    if ($species) {
    	$sql .= " $where species = $species";
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

    return @ids ? \@ids : undef;
}

=head2 fetch_external_ids

 Title    : fetch_external_ids
 Usage    : $ids = $xgia->fetch_external_ids($id_type, $species);
 Function : Fetch a list of all the distinct external gene IDs in the
 	    database.
 Returns  : A list ref of integer external gene IDs.
 Args	  : Optionally an integer ID type;
 	    optionally an integer species number.

=cut

sub fetch_external_ids
{
    my ($self, $id_type, $species) = @_;

    my $sql = qq{select distinct(external_id) from external_gene_ids};

    my $where = "where";
    if ($id_type) {
    	$sql .= " $where id_type = $id_type";
	$where = "and";
    }

    if ($species) {
    	$sql .= " $where species = $species";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching external gene IDs\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching external gene IDs\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($id) = $sth->fetchrow_array) {
	push @ids, $id;
    }

    return @ids ? \@ids : undef;
}

=head2 fetch_by_external_id

 Title    : fetch_by_external_id
 Usage    : $xgis = $xgia->fetch_by_external_id($id, $id_type, $species);
 Function : Fetch one or more external gene ID records from the database
 	    by external gene ID.
 Returns  : A list ref of ExternalGeneID objects.
 Args	  : An external ID string,
	    optionally an integer ID type;
 	    optionally an integer species number.

=cut

sub fetch_by_external_id
{
    my ($self, $id, $id_type, $species) = @_;

    return if !$id;

    my $sql = qq{select gene_pair_id, external_id, id_type, species
    		from external_gene_ids where external_id = $id};

    if ($id_type) {
    	$sql .= " and id_type = $id_type";
    }

    if ($species) {
    	$sql .= " and species = $species";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching external gene ID record(s)\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching external gene ID record(s)\n" . $self->errstr;
	return;
    }

    my @ext_ids;
    while (my @row = $sth->fetchrow_array) {
	push @ext_ids, OPOSSUM::ExternalGeneID->new(
					-gene_pair_id	=> $row[0],
					-external_id	=> $row[1],
					-id_type	=> $row[2],
					-species	=> $row[3]);
    }
    $sth->finish;

    return @ext_ids ? \@ext_ids : undef;
}

=head2 fetch_by_gene_pair_id

 Title    : fetch_by_gene_pair_id
 Usage    : $xgis = $xgia->fetch_by_gene_pair_id($id, $id_type, $species);
 Function : Fetch one or more external gene ID records from the database
 	    by gene pair ID.
 Returns  : A list ref of ExternalGeneID objects.
 Args	  : An integer gene pair ID,
	    optionally an integer ID type;
 	    optionally an integer species number.

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $id, $id_type, $species) = @_;

    return if !$id;

    my $sql = qq{select gene_pair_id, external_id, id_type, species
    		from external_gene_ids where gene_pair_id = $id};

    if ($id_type) {
    	$sql .= " and id_type = $id_type";
    }

    if ($species) {
    	$sql .= " and species = $species";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching external gene ID record(s)\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching external gene ID record(s)\n" . $self->errstr;
	return;
    }

    my @ext_ids;
    while (my @row = $sth->fetchrow_array) {
	push @ext_ids, OPOSSUM::ExternalGeneID->new(
					-gene_pair_id	=> $row[0],
					-external_id	=> $row[1],
					-id_type	=> $row[2],
					-species	=> $row[3]);
    }
    $sth->finish;

    return @ext_ids ? \@ext_ids : undef;
}

=head2 fetch

 Title    : fetch
 Usage    : $xgis = $xgia->fetch($where_clause);
 Function : Fetch one or more external gene ID records from the database
 	    with an optional where clause.
 Returns  : A list ref of ExternalGeneID objects.
 Args	  : Optionally an SQL where clause string.

=cut

sub fetch
{
    my ($self, $where_clause) = @_;

    my $sql = qq{select gene_pair_id, external_id, id_type, species
    		from external_gene_ids};

    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching external gene ID record(s)\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching external gene ID record(s)\n" . $self->errstr;
	return;
    }

    my @ext_ids;
    while (my @row = $sth->fetchrow_array) {
	push @ext_ids, OPOSSUM::ExternalGeneID->new(
					    -gene_pair_id	=> $row[0],
					    -external_id	=> $row[1],
					    -id_type		=> $row[2],
					    -species		=> $row[3]);
    }
    $sth->finish;

    return @ext_ids ? \@ext_ids : undef;
}

1;
