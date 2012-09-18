=head1 NAME

OPOSSUM::DBSQL::ExonAdaptor - Adaptor for MySQL queries to retrieve and
store exon information.

=head1 SYNOPSIS

$ea = $db_adaptor->get_ExonAdaptor();

=head1 DESCRIPTION

The exons table of the oPOSSUM database stores the exons associated with
the gene_pair records.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::ExonAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::Exon;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

=head2 new

 Title   : new
 Usage   : $ea = OPOSSUM::DBSQL::ExonAdaptor->new($db_adaptor);
 Function: Construct a new ExonAdaptor object
 Args    : An OPOSSUM::DBSQL::DBAdaptor object
 Returns : a new OPOSSUM::DBSQL::ExonAdaptor object

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_by_gene_pair_id

 Title   : fetch_by_gene_pair_id
 Usage   : $exons = $gpa->fetch_by_gene_pair_id($gene_pair_id, $species);
 Function: Fetch all the exons from the DB for a given species by
	   gene_pair_id. Exons are ordered by start coordinate.
 Args    : The gene_pair_id, species number.
 Returns : An OPOSSUM::Exon object.

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $gpid, $species) = @_;

    my $sql = qq{
		    select gene_pair_id, species, exon_type, start, end,
			    rel_start, rel_end
		    from exons
		    where gene_pair_id = $gpid and species = $species
		    order by start
		};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching species $species exons for gene_pair_id $gpid\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching species $species exons for gene_pair_id $gpid\n"
		. $self->errstr;
	return;
    }

    my @exons;
    while (my @row = $sth->fetchrow_array) {
	push @exons, OPOSSUM::Exon->new(
					-gene_pair_id	=> $row[0],
					-species	=> $row[1],
					-type		=> $row[2],
	    				-start		=> $row[3],
	    				-end		=> $row[4],
	    				-rel_start	=> $row[5],
	    				-rel_end	=> $row[6]);
    }

    return @exons ? \@exons : undef;
}

=head2 store

 Title   : store
 Usage   : $ea->store($exon);
 Function: Store exon in the database.
 Args    : An OPOSSUM::Exon object
 Returns : True on success, false otherwise.

=cut

sub store
{
    my ($self, $exon) = @_;

    my $sql = qq{insert into exons
		    (gene_pair_id, species, exon_type, start, end,
		     rel_start, rel_end)
		    values (?, ?, ?, ?, ?, ?, ?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert exon statement\n" . $self->errstr;
	return;
    }

    if (!$sth->execute($exon->gene_pair_id, $exon->species, $exon->type,
    			$exon->start, $exon->end, $exon->rel_start,
			$exon->rel_end))
    {
	carp sprintf("Error inserting species %s exon for gene_pair_id %d"
		. $self->errstr, $exon->species, $exon->gene_pair_id);
	return 0;
    }

    return 1;
}

=head2 store_list

 Title   : store_list
 Usage   : $ea->store_list($exons, $gpid, $species);
 Function: Store exons in the database.
 Args    : A listref of OPOSSUM::Exon objects,
 	   A GenePair ID,
 	   A species number
 Returns : True on success, false otherwise.

=cut

sub store_list
{
    my ($self, $exons, $gpid, $species) = @_;

    my $sql = qq{insert into exons
		    (gene_pair_id, species, exon_type, start, end, rel_start,
		     rel_end)
		    values (?, ?, ?, ?, ?, ?, ?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert exon statement\n" . $self->errstr;
	return;
    }

    my $ok = 1;
    foreach my $exon (@$exons) {
	if (!$sth->execute($gpid, $species, $exon->type,
			    $exon->start, $exon->end, $exon->rel_start,
			    $exon->rel_end))
	{
	    carp sprintf("Error inserting species %s exon for gene_pair_id %s\n"
			    . $self->errstr,
			    $species, $gpid);
	    # keep trying to store exons but return error status...
	    $ok = 0;
	}
    }

    return $ok;
}

1;
