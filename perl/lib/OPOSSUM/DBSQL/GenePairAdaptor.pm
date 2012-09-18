=head1 NAME

OPOSSUM::DBSQL::GenePairAdaptor - Adaptor for MySQL queries to retrieve and
store GenePair objects.

=head1 SYNOPSIS

$gpa = $db_adaptor->get_GenePairAdaptor();

=head1 DESCRIPTION

The gene_pairs table of the oPOSSUM database maps the orthologous Ensembl gene
IDs of two different species (i.e. human and mouse).

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::GenePairAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::GenePair;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

=head2 new

 Title   : new
 Usage   : $gpa = OPOSSUM::DBSQL::GenePairAdaptor->new($db_adaptor);
 Function: Construct a new GenePairAdaptor object
 Args    : An OPOSSUM::DBSQL::DBAdaptor object
 Returns : a new OPOSSUM::DBSQL::GenePairAdaptor object

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_gene_pair_ids

 Title   : fetch_gene_pair_ids
 Usage   : $ids = $gpa->fetch_gene_pair_ids($where);
 Function: Fetch list of gene pair IDs from the DB.
 Args    : Optionally a where clause.
 Returns : Reference to a list of internal gene pair IDs. If no where clause
 	   is provided, returns all gene pair IDs in the database.

=cut

sub fetch_gene_pair_ids
{
    my ($self, $where_clause) = @_;

    my $sql = "select gene_pair_id from gene_pairs";
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

=head2 fetch_gene_pair_id_fields

 Title   : fetch_gene_pair_id_fields
 Usage   : $ids = $gpa->fetch_gene_pair_id_fields($field, $where);
 Function: Fetch list of IDs of type specified by $field from the DB.
 Args    : Optionally a field type and where clause.
 Returns : Reference to a list of IDs. If no field type is specified,
 	   returns internal gene pair IDs, otherwise the IDs stored in the
	   given field. If no where clause is provided, returns all IDs in
	   the database.

=cut

sub fetch_gene_pair_id_fields
{
    my ($self, $id_field, $where_clause) = @_;

    if (!$id_field) {
    	return $self->fetch_gene_pair_ids;
    }

    my $sql = "select distinct $id_field from gene_pairs";
    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

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

=head2 fetch_by_gene_pair_id

 Title   : fetch_by_gene_pair_id
 Usage   : $gene_pair = $gpa->fetch_by_gene_pair_id($gene_pair_id);
 Function: Fetch a gene pair object from the DB using it's gene pair ID.
 Args    : The unique internal gene pair ID.
 Returns : An OPOSSUM::GenePair object.

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $gene_pair_id) = @_;

    my $sql = qq{select gene_pair_id,
			ortholog_type,
			ensembl_id1,
			ensembl_id2,
			symbol1,
			symbol2,
			description1,
			description2,
			chr1,
			chr2,
			strand1,
			strand2,
			start1,
			start2,
			end1,
			end2
		from gene_pairs
		where gene_pair_id = $gene_pair_id
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair with gene_pair_id = $gene_pair_id\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching gene pair with gene_pair_id = $gene_pair_id\n"
		. $self->errstr;
	return;
    }

    my $gene_pair;
    if (my @row = $sth->fetchrow_array) {
	$gene_pair = OPOSSUM::GenePair->new(
				-id		=> $row[0],
				-ortholog_type	=> $row[1],
				-ensembl_id1	=> $row[2],
				-ensembl_id2	=> $row[3],
				-symbol1	=> $row[4],
				-symbol2	=> $row[5],
				-description1	=> $row[6],
				-description2	=> $row[7],
				-chr1		=> $row[8],
				-chr2		=> $row[9],
				-strand1	=> $row[10],
				-strand2	=> $row[11],
				-start1		=> $row[12],
				-start2		=> $row[13],
				-end1		=> $row[14],
				-end2		=> $row[15]);
    }
    $sth->finish;

    return $gene_pair;
}

=head2 fetch_by_gene_pair_id_list

 Title   : fetch_by_gene_pair_id_list
 Usage   : $gene_pairs = $gpa->fetch_by_gene_pair_id_list($id_list);
 Function: Fetch a list of gene pair objects from the DB according to a list
 	   of gene pair IDs.
 Args    : A reference to a list of unique internal gene pair IDs.
 Returns : A reference to a list of OPOSSUM::GenePair objects.

=cut

sub fetch_by_gene_pair_id_list
{
    my ($self, $gene_pair_ids) = @_;

    my $sql = qq{select gene_pair_id,
			ortholog_type,
			ensembl_id1,
			ensembl_id2,
			symbol1,
			symbol2,
			description1,
			description2,
			chr1,
			chr2,
			strand1,
			strand2,
			start1,
			start2,
			end1,
			end2
		from gene_pairs
		where gene_pair_id = ?
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pairs\n" . $self->errstr;
	return;
    }

    my @gene_pairs;
    foreach my $gene_pair_id (@$gene_pair_ids) {
	if (!$sth->execute($gene_pair_id)) {
	    carp "error fetching gene pair for gene pair ID $gene_pair_id\n"
	    	. $self->errstr;
	    return;
	}
	if (my @row = $sth->fetchrow_array) {
	    push @gene_pairs, OPOSSUM::GenePair->new(
				-id		=> $row[0],
				-ortholog_type	=> $row[1],
				-ensembl_id1	=> $row[2],
				-ensembl_id2	=> $row[3],
				-symbol1	=> $row[4],
				-symbol2	=> $row[5],
				-description1	=> $row[6],
				-description2	=> $row[7],
				-chr1		=> $row[8],
				-chr2		=> $row[9],
				-strand1	=> $row[10],
				-strand2	=> $row[11],
				-start1		=> $row[12],
				-start2		=> $row[13],
				-end1		=> $row[14],
				-end2		=> $row[15]);
	}
    }
    $sth->finish;

    return @gene_pairs ? \@gene_pairs : undef;
}

sub fetch_by_ensembl_id
{
    my ($self, $ensembl_id, $which) = @_;

    return if !$ensembl_id;
    $which = 1 if !$which;

    return if $which ne '1' && $which ne '2';

    my $sql = qq{select gene_pair_id,
			ortholog_type,
			ensembl_id1,
			ensembl_id2,
			symbol1,
			symbol2,
			description1,
			description2,
			chr1,
			chr2,
			strand1,
			strand2,
			start1,
			start2,
			end1,
			end2
		from gene_pairs
		where ensembl_id$which = '$ensembl_id'
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair with ensembl_id$which = $ensembl_id\n"
		. $self->errstr;
	return;
    }
    if (!$sth->execute) {
	carp "error fetching gene pair with ensembl_id$which = $ensembl_id\n"
		. $self->errstr;
	return;
    }

    my $gene_pair;
    if (my @row = $sth->fetchrow_array) {
	$gene_pair = OPOSSUM::GenePair->new(
				-id		=> $row[0],
				-ortholog_type	=> $row[1],
				-ensembl_id1	=> $row[2],
				-ensembl_id2	=> $row[3],
				-symbol1	=> $row[4],
				-symbol2	=> $row[5],
				-description1	=> $row[6],
				-description2	=> $row[7],
				-chr1		=> $row[8],
				-chr2		=> $row[9],
				-strand1	=> $row[10],
				-strand2	=> $row[11],
				-start1		=> $row[12],
				-start2		=> $row[13],
				-end1		=> $row[14],
				-end2		=> $row[15]);
    }
    $sth->finish;

    return $gene_pair;
}

=head2 fetch_by_ensembl_id1

 Title   : fetch_by_ensembl_id1
 Usage   : $gene_pair = $gpa->fetch_by_ensembl_id1($ensembl_id);
 Function: Fetch a gene pair object from the DB by it's species 1 Ensembl ID.
 Args    : The species 1 Ensembl ID of this gene pair.
 Returns : An OPOSSUM::GenePair object.

=cut

sub fetch_by_ensembl_id1
{
    my ($self, $ensembl_id) = @_;

    return $self->fetch_by_ensembl_id($ensembl_id, 1);
}

=head2 fetch_by_ensembl_id2

 Title   : fetch_by_ensembl_id2
 Usage   : $gene_pair = $gpa->fetch_by_ensembl_id2($ensembl_id);
 Function: Fetch a gene pair object from the DB by it's species 2 Ensembl ID.
 Args    : The species 2 Ensembl ID of this gene pair.
 Returns : An OPOSSUM::GenePair object.

=cut

sub fetch_by_ensembl_id2
{
    my ($self, $ensembl_id) = @_;

    return $self->fetch_by_ensembl_id($ensembl_id, 2);
}

sub fetch_by_symbol
{
    my ($self, $symbol, $which) = @_;

    return if !$symbol;
    $which = 1 if !$which;

    return if $which ne '1' && $which ne '2';
    if ($which eq '2') {
    	carp "Warning: symbol2 is not guaranteed to be unique"
		. " - fetching first matching entry\n";
    }

    my $sql = qq{select gene_pair_id,
			ortholog_type,
			ensembl_id1,
			ensembl_id2,
			symbol1,
			symbol2,
			description1,
			description2,
			chr1,
			chr2,
			strand1,
			strand2,
			start1,
			start2,
			end1,
			end2
		from gene_pairs
		where symbol$which = '$symbol'
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair with symbol$which"
		. " = $symbol\n" . $self->errstr;
	return;
    }
    if (!$sth->execute) {
	carp "error fetching gene pair with symbol$which"
		. " = $symbol\n" . $self->errstr;
	return;
    }
    my $gene_pair;
    if (my @row = $sth->fetchrow_array) {
	$gene_pair = OPOSSUM::GenePair->new(
				-id		=> $row[0],
				-ortholog_type	=> $row[1],
				-ensembl_id1	=> $row[2],
				-ensembl_id2	=> $row[3],
				-symbol1	=> $row[4],
				-symbol2	=> $row[5],
				-description1	=> $row[6],
				-description2	=> $row[7],
				-chr1		=> $row[8],
				-chr2		=> $row[9],
				-strand1	=> $row[10],
				-strand2	=> $row[11],
				-start1		=> $row[12],
				-start2		=> $row[13],
				-end1		=> $row[14],
				-end2		=> $row[15]);
    }
    $sth->finish;

    return $gene_pair;
}

=head2 fetch_by_symbol1

 Title   : fetch_by_symbol1
 Usage   : $gene_pair = $gpa->fetch_by_symbol1($symbol);
 Function: Fetch a gene pair object from the DB by it's species 1 display label.
 Args    : The species 1 display label of this gene pair.
 Returns : An OPOSSUM::GenePair object.

=cut

sub fetch_by_symbol1
{
    my ($self, $symbol) = @_;

    return $self->fetch_by_symbol($symbol, 1);
}

=head2 fetch_by_symbol2

 Title   : fetch_by_symbol2
 Usage   : $gene_pair = $gpa->fetch_by_symbol2($symbol);
 Function: Fetch a gene pair object from the DB by it's species 2 display label.
 Args    : The species 2 display label of this gene pair.
 Returns : An OPOSSUM::GenePair object.

=cut

sub fetch_by_symbol2
{
    my ($self, $symbol) = @_;

    return $self->fetch_by_symbol($symbol, 2);
}

=head2 fetch_by_external_id

 Title   : fetch_by_external_id
 Usage   : $gene_pair = $gpa->fetch_by_external_id($ext_id, $ext_id_type,
						    $species);
 Function: Fetch a gene pair object from the DB by an external gene ID.
 Args    : The external ID, external ID type and species number.
 Returns : An OPOSSUM::GenePair object.

=cut

sub fetch_by_external_id
{
    my ($self, $ext_id, $ext_id_type, $species) = @_;

    return if !$ext_id || !$ext_id_type;
    $species = 1 if !$species;

    if ($species ne '1' && $species ne '2') {
    	carp "species must be either 1 or 2\n";
	return;
    }

    my $sql = qq{select gp.gene_pair_id,
			gp.ortholog_type,
			gp.ensembl_id1,
			gp.ensembl_id2,
			gp.symbol1,
			gp.symbol2,
			gp.description1,
			gp.description2,
			gp.chr1,
			gp.chr2,
			gp.strand1,
			gp.strand2,
			gp.start1,
			gp.start2,
			gp.end1,
			gp.end2
		from gene_pairs gp, external_gene_ids xgi
		where gp.gene_pair_id = xgi.gene_pair_id
		    and xgi.species = $species
		    and xgi.id_type = $ext_id_type
		    and xgi.external_id = '$ext_id'
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair with external ID"
		. " = $ext_id\n" . $self->errstr;
	return;
    }
    if (!$sth->execute) {
	carp "error fetching gene pair with external ID"
		. " = $ext_id\n" . $self->errstr;
	return;
    }
    my $gene_pair;
    if (my @row = $sth->fetchrow_array) {
	$gene_pair = OPOSSUM::GenePair->new(
				-id		=> $row[0],
				-ortholog_type	=> $row[1],
				-ensembl_id1	=> $row[2],
				-ensembl_id2	=> $row[3],
				-symbol1	=> $row[4],
				-symbol2	=> $row[5],
				-description1	=> $row[6],
				-description2	=> $row[7],
				-chr1		=> $row[8],
				-chr2		=> $row[9],
				-strand1	=> $row[10],
				-strand2	=> $row[11],
				-start1		=> $row[12],
				-start2		=> $row[13],
				-end1		=> $row[14],
				-end2		=> $row[15]);
    }
    $sth->finish;

    return $gene_pair;
}

=head2 store

 Title   : store
 Usage   : $id = $gpa->store($gene_pair);
 Function: Store gene pair in the database.
 Args    : The gene pair (OPOSSUM::GenePair) to store.
 Returns : A database ID of the newly stored gene pair.

=cut

sub store
{
    my ($self, $gene_pair) = @_;

    if (!ref $gene_pair || !$gene_pair->isa('OPOSSUM::GenePair')) {
    	carp "Not an OPOSSUM::GenePair object";
	return;
    }

    my $sql = qq{insert into gene_pairs
		    (ortholog_type, ensembl_id1, ensembl_id2, symbol1, symbol2,
		     description1, description2, chr1, chr2, start1, start2,
		     end1, end2, strand1, strand2)
		    values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert gene pair statement\n" . $self->errstr;
	return;
    }

    if (!$sth->execute($gene_pair->ortholog_type,
    			$gene_pair->ensembl_id1,
    			$gene_pair->ensembl_id2,
    			$gene_pair->symbol1,
			$gene_pair->symbol2,
    			$gene_pair->description1,
			$gene_pair->description2,
    			$gene_pair->chr1,
			$gene_pair->chr2,
    			$gene_pair->start1,
			$gene_pair->start2,
    			$gene_pair->end1,
			$gene_pair->end2,
    			$gene_pair->strand1,
			$gene_pair->strand2))
    {
    	carp "Error inserting gene pair\n" . $self->errstr;
	return;
    }
    $sth->finish;

    return $sth->{'mysql_insertid'};
}

1;
