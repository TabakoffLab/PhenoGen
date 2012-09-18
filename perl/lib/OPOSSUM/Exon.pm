=head1 NAME

OPOSSUM::Exon - Exon object (models oPOSSUM DB exons table record)

=head1 DESCRIPTION

A Exon object models a record retrieved from the exons table of the oPOSSUM DB.
It contains the positional information of the exon in both absolute
(chromosomal) coordinates, and coordinates relative to the Alignment object
with which it is associated.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::Exon;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $exon = OPOSSUM::Exon->new(
		    -gene_pair_id		=> 1,
		    -species			=> 1,
		    -type			=> '',
		    -start			=> 63025275,
		    -end			=> 63025474,
		    -rel_start			=> 1,
		    -rel_end			=> 200);

 Function: Construct a new Exon object
 Returns : a new OPOSSUM::Exon object

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
		    %args
		}, ref $class || $class;

    return $self;
}

=head2 gene_pair_id

 Title   : gene_pair_id
 Usage   : $gpid = $exon->gene_pair_id() or $exon->gene_pair_id($gpid);

 Function: Get/set the ID of the GenePair object associated with this
 	   Exon.
 Returns : A numeric ID
 Args    : None or a numeric ID

=cut

sub gene_pair_id
{
    my ($self, $id) = @_;

    if ($id) {
	$self->{-gene_pair_id} = $id;
    }

    return $self->{-gene_pair_id}
}

=head2 species

 Title   : species
 Usage   : $species = $exon->species() or $exon->species($species);

 Function: Get/set the species number which this exon belongs to
 Returns : An integer
 Args    : None or a new species number 

=cut

sub species
{
    my ($self, $species) = @_;

    if ($species) {
	$self->{-species} = $species;
    }

    return $self->{-species};
}

=head2 type

 Title   : type
 Usage   : $type = $exon->type() or $exon->type($type);

 Function: Get/set the type of exon this is
 Returns : An string
 Args    : None or a new exon type string 

=cut

sub type
{
    my ($self, $type) = @_;

    if ($type) {
	$self->{-type} = $type;
    }

    return $self->{-type};
}

=head2 start

 Title   : start
 Usage   : $start = $exon->start() or $exon->start($start);

 Function: Get/set the chromosomal start position of this exon
 Returns : An integer
 Args    : None or a new exon start position 

=cut

sub start
{
    my ($self, $start) = @_;

    if ($start) {
	$self->{-start} = $start;
    }

    return $self->{-start};
}

=head2 end

 Title   : end
 Usage   : $end = $exon->end() or $exon->end($end);

 Function: Get/set the chromosomal end position of this exon
 Returns : An integer
 Args    : None or a new exon end position 

=cut

sub end
{
    my ($self, $end) = @_;

    if ($end) {
	$self->{-end} = $end;
    }

    return $self->{-end};
}

=head2 rel_start

 Title   : rel_start
 Usage   : $start = $exon->rel_start() or $exon->rel_start($start);

 Function: Get/set the relative start position of this exon with respect
 	   to the associated alignment record.
 Returns : An integer
 Args    : None or a new exon relative start site 

=cut

sub rel_start
{
    my ($self, $start) = @_;

    if ($start) {
	$self->{-rel_start} = $start;
    }

    return $self->{-rel_start};
}

=head2 rel_end

 Title   : rel_end
 Usage   : $end = $exon->rel_end() or $exon->rel_end($end);

 Function: Get/set the relative end position of this exon with respect
 	   to the associated alignment record.
 Returns : An integer
 Args    : None or a new exon relative end site 

=cut

sub rel_end
{
    my ($self, $end) = @_;

    if ($end) {
	$self->{-rel_end} = $end;
    }

    return $self->{-rel_end};
}

=head2 gene_pair

 Title   : gene_pair
 Usage   : $gp = $ex->gene_pair() or $ex->gene_pair($gp);

 Function: Get/set the GenePair that this exon is associated with.
 Returns : An OPOSSUM::GenePair object.
 Args    : None or an OPOSSUM::GenePair object.

=cut

sub gene_pair
{
    my ($self, $gp) = @_;

    if ($gp) {
	if ($gp->isa("OPOSSUM::GenePair")) {
	    $self->{-gene_pair} = $gp;
	} else {
	    carp "not an OPOSSUM::GenePair";
	    return undef;
	}
    }
    return $self->{-gene_pair};
}

=head2 alignment

 Title   : alignment
 Usage   : $alignment = $ex->alignment() or $ex->alignment($alignment);

 Function: Get/set the alignment associated with this exon
 Returns : An Alignment object
 Args    : None or a new Alignment object 

=cut

sub alignment
{
    my ($self, $aln) = @_;

    if ($aln) {
	if ($aln->isa("OPOSSUM::Alignment")) {
	    $self->{-alignment} = $aln;
	} else {
	    carp "not an OPOSSUM::Alignment";
	    return undef;
	}
    }
    return $self->{-alignment};
}

1;
