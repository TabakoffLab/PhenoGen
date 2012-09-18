=head1 NAME

OPOSSUM::GenePair - GenePair object (gene_pairs DB record)

=head1 DESCRIPTION

A GenePair object models a record retrieved from the gene_pairs table of the
oPOSSUM DB. The oPOSSUM database is built by first identifying all unique
one-to-one orthologous genes of a given pair of species (i.e. human and mouse)
from the Ensembl database.  These orthologs are stored in the gene_pairs table.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::GenePair;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $gp = OPOSSUM::GenePair->new(
			    -id			=> '123',
			    -ortholog_type	=> 'ortholog_one2one',
			    -ensembl_id1	=> 'ENSG00000165029',
			    -ensembl_id2	=> 'ENSMUSG00000015243',
			    -symbol1		=> 'ABCA1',
			    -symbol2		=> 'Abca1'
			    -description1	=> 'ATP-binding cassette...',
			    -description2	=> 'ATP-binding cassette...'
			    -chr1		=> '9',
			    -chr2		=> 4,
			    -strand1		=> -1,
			    -strand2		=> -1,
			    -start1		=> 106583104,
			    -start2		=> 53051888,
			    -end1		=> 106730339,
			    -end2		=> 53180992);

 Function: Construct a new GenePair object
 Returns : a new OPOSSUM::GenePair object

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
		    %args
		}, ref $class || $class;

    return $self;
}

=head2 id

 Title   : id
 Usage   : $id = $gp->id() or $gp->id('123');

 Function: Get/set the ID of the GenePair. This should be a unique
 	   identifier for this object within the implementation. If
	   the GenePair object was read from the oPOSSUM database,
	   this should be set to the value in the gene_pair_id column.
 Returns : A numeric ID
 Args    : None or a numeric ID

=cut

sub id
{
    my ($self, $id) = @_;

    if ($id) {
	$self->{-id} = $id;
    }

    return $self->{-id};
}

=head2 ortholog_type

 Title   : ortholog_type
 Usage   : $ot = $gp->ortholog_type()
 	   or $gp->ortholog_type('ortholog_one2one');

 Function: Get/set the type of ortholog of the GenePair as defined by
 	   Ensembl.
 Returns : A string
 Args    : None or an ortholog type string

=cut

sub ortholog_type
{
    my ($self, $type) = @_;

    if ($type) {
	$self->{-ortholog_type} = $type;
    }

    return $self->{-ortholog_type};
}

=head2 ensembl_id1

 Title   : ensembl_id1
 Usage   : $id = $gp->ensembl_id1() or $gp->ensembl_id1('ENSG00000165029');

 Function: Get/set the species 1 Ensembl ID of the GenePair.
 Returns : A string
 Args    : None or an Ensembl ID string

=cut

sub ensembl_id1
{
    my ($self, $ensembl_id) = @_;

    if ($ensembl_id) {
	$self->{-ensembl_id1} = $ensembl_id;
    }

    return $self->{-ensembl_id1};
}

=head2 ensembl_id2

 Title   : ensembl_id2
 Usage   : $id = $gp->ensembl_id2() or $gp->ensembl_id2('ENSG00000165029');

 Function: Get/set the species 2 Ensembl ID of the GenePair.
 Returns : A string
 Args    : None or an Ensembl ID string

=cut

sub ensembl_id2
{
    my ($self, $ensembl_id) = @_;

    if ($ensembl_id) {
	$self->{-ensembl_id2} = $ensembl_id;
    }

    return $self->{-ensembl_id2};
}

=head2 symbol1

 Title   : symbol1
 Usage   : $label = $gp->symbol1() or $gp->symbol1('ABCA1');

 Function: Get/set the species 1 symbol of the GenePair. This should
 	   be a generally accepted name for this gene, i.e. a HUGO.
 Returns : A string
 Args    : None or a string

=cut

sub symbol1
{
    my ($self, $symbol) = @_;

    if ($symbol) {
	$self->{-symbol1} = $symbol;
    }

    return $self->{-symbol1};
}

=head2 symbol2

 Title   : symbol2
 Usage   : $label = $gp->symbol2() or $gp->symbol2('Abca1');

 Function: Get/set the species 2 symbol of the GenePair. This should
 	   be a generally accepted name for this gene.
 Returns : A string
 Args    : None or a string

=cut

sub symbol2
{
    my ($self, $symbol) = @_;

    if ($symbol) {
	$self->{-symbol2} = $symbol;
    }

    return $self->{-symbol2};
}

=head2 description1

 Title   : description1
 Usage   : $desc = $gp->description1() or $gp->description1($desc);

 Function: Get/set the species 1 gene description of the GenePair.
 Returns : A string
 Args    : None or a string

=cut

sub description1
{
    my ($self, $description) = @_;

    if ($description) {
	$self->{-description1} = $description;
    }

    return $self->{-description1};
}

=head2 description2

 Title   : description2
 Usage   : $desc = $gp->description2() or $gp->description2($desc);

 Function: Get/set the species 2 gene description of the GenePair.
 Returns : A string
 Args    : None or a string

=cut

sub description2
{
    my ($self, $description) = @_;

    if ($description) {
	$self->{-description2} = $description;
    }

    return $self->{-description2};
}

=head2 chr1

 Title   : chr1
 Usage   : $chr = $gp->chr1() or $gp->chr1($chr);

 Function: Get/set the chromosome name of the species 1 gene.
 Returns : A string
 Args    : None or a chromosome name

=cut

sub chr1
{
    my ($self, $chr) = @_;

    if ($chr) {
	$self->{-chr1} = $chr;
    }

    return $self->{-chr1};
}

=head2 chr2

 Title   : chr2
 Usage   : $chr = $gp->chr2() or $gp->chr2($chr);

 Function: Get/set the chromosome name of the species 2 gene.
 Returns : A string
 Args    : None or a chromosome name

=cut

sub chr2
{
    my ($self, $chr) = @_;

    if ($chr) {
	$self->{-chr2} = $chr;
    }

    return $self->{-chr2};
}

=head2 strand1

 Title   : strand1
 Usage   : $strand = $gp->strand1() or $gp->strand1(1);

 Function: Get/set the species 1 strand of the PromoterPair.
 Returns : 1 or -1
 Args    : None or a new strand value

=cut

sub strand1
{
    my ($self, $strand) = @_;

    if ($strand) {
	$self->{-strand1} = $strand;
    }

    return $self->{-strand1};
}

=head2 strand2

 Title   : strand2
 Usage   : $strand = $gp->strand2() or $gp->strand2(-1);

 Function: Get/set the species 2 strand of the PromoterPair.
 Returns : 1 or -1
 Args    : None or a new strand value

=cut

sub strand2
{
    my ($self, $strand) = @_;

    if ($strand) {
	$self->{-strand2} = $strand;
    }

    return $self->{-strand2};
}

=head2 start1

 Title   : start1
 Usage   : $start = $gp->start1() or $gp->start1($start);

 Function: Get/set the species 1 gene start position
 Returns : An integer
 Args    : None or a new gene start site 

=cut

sub start1
{
    my ($self, $start) = @_;

    if ($start) {
	$self->{-start1} = $start;
    }

    return $self->{-start1};
}

=head2 start2

 Title   : start2
 Usage   : $start = $gp->start2() or $gp->start2($start);

 Function: Get/set the species 2 gene start position
 Returns : An integer
 Args    : None or a new gene start site 

=cut

sub start2
{
    my ($self, $start) = @_;

    if ($start) {
	$self->{-start2} = $start;
    }

    return $self->{-start2};
}

=head2 end1

 Title   : end1
 Usage   : $end = $gp->end1() or $gp->end1($end);

 Function: Get/set the species 1 gene end position
 Returns : An integer
 Args    : None or a new gene end site 

=cut

sub end1
{
    my ($self, $end) = @_;

    if ($end) {
	$self->{-end1} = $end;
    }

    return $self->{-end1};
}

=head2 end2

 Title   : end2
 Usage   : $end = $gp->end2() or $gp->end2($end);

 Function: Get/set the species 2 gene end position
 Returns : An integer
 Args    : None or a new gene end site 

=cut

sub end2
{
    my ($self, $end) = @_;

    if ($end) {
	$self->{-end2} = $end;
    }

    return $self->{-end2};
}

1;
