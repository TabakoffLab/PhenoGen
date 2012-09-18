=head1 NAME

OPOSSUM::PromoterPair - PromoterPair object (promoter_pairs DB record)

=head1 DESCRIPTION

A PromoterPair object models a record retrieved from the promoter_pairs table
of the oPOSSUM DB. It contains the positional information of the promoter in
both absolute (chromosomal) coordinates, and coordinates relative to the
Alignment object with which it is associated.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::PromoterPair;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $pp = OPOSSUM::PromoterPair->new(
		    -id				=> 1,
		    -gene_pair_id		=> 1,
		    -primary_promoter		=> 0,
		    -chr1			=> '4',
		    -chr2			=> '9',
		    -strand1			=> '1',
		    -strand2			=> '1',
		    -start1			=> 103025275,
		    -start2			=> 52264891,
		    -end1			=> 103075274,
		    -end2			=> 52330706,
		    -tss1			=> 103070274,
		    -tss2			=> 52325706,
		    -rel_start1			=> 1,
		    -rel_start2			=> 1,
		    -rel_end1			=> 20000,
		    -rel_end2			=> 20000,
		    -rel_tss1			=> 10001,
		    -rel_tss2			=> 10001,
		    -cage_evidence1		=> 1,
		    -cage_evidence2		=> 1,
		    -ensembl_transcript_id1	=> 'ENST00000369658',
		    -ensembl_transcript_id2	=> 'ENSMUST00000069988');

 Function: Construct a new PromoterPair object
 Returns : a new OPOSSUM::PromoterPair object

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
 Usage   : $id = $pp->id() or $pp->id('33992');

 Function: Get/set the ID of the PromoterPair. This should be a unique
 	   identifier for this object within the implementation. If
	   the PromoterPair object was read from the oPOSSUM database,
	   this should be set to the value in the promoter_pair_id column.
 Returns : A numeric ID
 Args    : None or a numeric ID

=cut

sub id
{
    my ($self, $id) = @_;

    if ($id) {
	$self->{-id} = $id;
    }

    return $self->{-id}
}

=head2 gene_pair_id

 Title   : gene_pair_id
 Usage   : $gpid = $pp->gene_pair_id() or $pp->gene_pair_id($gpid);

 Function: Get/set the ID of the GenePair object associated with this
 	   PromoterPair.
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

#=head2 alignment_id
#
# Title   : alignment_id
# Usage   : $aln_id = $pp->alignment_id() or $pp->alignment_id($aln_id);
#
# Function: Get/set the ID of the Alignment object associated with this
# 	   PromoterPair.
# Returns : A numeric ID
# Args    : None or a numeric ID
#
#=cut
#
#sub alignment_id
#{
#    my ($self, $id) = @_;
#
#    if ($id) {
#	$self->{-alignment_id} = $id;
#    }
#
#    return $self->{-alignment_id}
#}

=head2 primary_promoter

 Title   : primary_promoter
 Usage   : $bool = $pp->primary_promoter()
	   or $pp->primary_promoter($bool);

 Function: Get/set the primary promoter status.
 Returns : A boolean
 Args    : None or a boolean value

=cut

sub primary_promoter
{
    my ($self, $bool) = @_;

    if ($bool) {
	$self->{-primary_promoter} = $bool;
    }

    return $self->{-primary_promoter}
}

=head2 chr1

 Title   : chr1
 Usage   : $chr = $pp->chr1() or $pp->chr1($chr);

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
 Usage   : $chr = $pp->chr2() or $pp->chr2($chr);

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
 Usage   : $strand = $pp->strand1() or $pp->strand1(1);

 Function: Get/set the strand of the species 1 gene from which this
 	   PromoterPair comes.
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
 Usage   : $strand = $pp->strand2() or $pp->strand2(-1);

 Function: Get/set the strand of the species 2 gene from which this
 	   PromoterPair comes.
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
 Usage   : $start = $pp->start1() or $pp->start1($start);

 Function: Get/set the species 1 chromosomal start position of this promoter
	   region
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
 Usage   : $start = $pp->start2() or $pp->start2($start);

 Function: Get/set the species 2 chromosomal start position of this promoter
	   region
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
 Usage   : $end = $pp->end1() or $pp->end1($end);

 Function: Get/set the species 1 chromosomal end position of this promoter
 	   region
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
 Usage   : $end = $pp->end2() or $pp->end2($end);

 Function: Get/set the species 2 chromosomal end position of this promoter
 	   region
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

=head2 tss1

 Title   : tss1
 Usage   : $tss = $pp->tss1() or $pp->tss1($tss);

 Function: Get/set the chromosomal position of the species 1 transcription
 	   start site
 Returns : An integer
 Args    : None or a new transcription start site 

=cut

sub tss1
{
    my ($self, $tss) = @_;

    if ($tss) {
	$self->{-tss1} = $tss;
    }

    return $self->{-tss1};
}

=head2 tss2

 Title   : tss2
 Usage   : $tss = $pp->tss2() or $pp->tss2($tss);

 Function: Get/set the chromosomal position of the species 2 transcription
 	   start site
 Returns : An integer
 Args    : None or a new transcription start site 

=cut

sub tss2
{
    my ($self, $tss) = @_;

    if ($tss) {
	$self->{-tss2} = $tss;
    }

    return $self->{-tss2};
}

=head2 rel_start1

 Title   : rel_start1
 Usage   : $start = $pp->rel_start1() or $pp->rel_start1($start);

 Function: Get/set the species 1 relative start position of this promoter
	   region
 Returns : An integer
 Args    : None or a new gene start site 

=cut

sub rel_start1
{
    my ($self, $start) = @_;

    if ($start) {
	$self->{-rel_start1} = $start;
    }

    return $self->{-rel_start1};
}

=head2 rel_start2

 Title   : rel_start2
 Usage   : $start = $pp->rel_start2() or $pp->rel_start2($start);

 Function: Get/set the species 2 relative start position of this promoter
	   region
 Returns : An integer
 Args    : None or a new gene start site 

=cut

sub rel_start2
{
    my ($self, $start) = @_;

    if ($start) {
	$self->{-rel_start2} = $start;
    }

    return $self->{-rel_start2};
}

=head2 rel_end1

 Title   : rel_end1
 Usage   : $end = $pp->rel_end1() or $pp->rel_end1($end);

 Function: Get/set the species 1 relative end position of this promoter
 	   region
 Returns : An integer
 Args    : None or a new gene end site 

=cut

sub rel_end1
{
    my ($self, $end) = @_;

    if ($end) {
	$self->{-rel_end1} = $end;
    }

    return $self->{-rel_end1};
}

=head2 rel_end2

 Title   : rel_end2
 Usage   : $end = $pp->rel_end2() or $pp->rel_end2($end);

 Function: Get/set the species 2 relative end position of this promoter
 	   region
 Returns : An integer
 Args    : None or a new gene end site 

=cut

sub rel_end2
{
    my ($self, $end) = @_;

    if ($end) {
	$self->{-rel_end2} = $end;
    }

    return $self->{-rel_end2};
}

=head2 rel_tss1

 Title   : rel_tss1
 Usage   : $tss = $pp->rel_tss1() or $pp->rel_tss1($tss);

 Function: Get/set the relative position of the species 1 transcription
 	   start site
 Returns : An integer
 Args    : None or a new transcription start site 

=cut

sub rel_tss1
{
    my ($self, $tss) = @_;

    if ($tss) {
	$self->{-rel_tss1} = $tss;
    }

    return $self->{-rel_tss1};
}

=head2 rel_tss2

 Title   : rel_tss2
 Usage   : $tss = $pp->rel_tss2() or $pp->rel_tss2($tss);

 Function: Get/set the relative position of the species 2 transcription
 	   start site
 Returns : An integer
 Args    : None or a new transcription start site 

=cut

sub rel_tss2
{
    my ($self, $tss) = @_;

    if ($tss) {
	$self->{-rel_tss2} = $tss;
    }

    return $self->{-rel_tss2};
}

=head2 cage_evidence1

 Title   : cage_evidence1
 Usage   : $bool = $pp->cage_evidence1()
	   or $pp->cage_evidence1($bool);

 Function: Get/set weather TSS1 is supported by CAGE evidence
 Returns : A boolean
 Args    : None or a boolean value

=cut

sub cage_evidence1
{
    my ($self, $bool) = @_;

    if ($bool) {
	$self->{-cage_evidence1} = $bool;
    }

    return $self->{-cage_evidence1}
}

=head2 cage_evidence2

 Title   : cage_evidence2
 Usage   : $bool = $pp->cage_evidence2()
	   or $pp->cage_evidence2($bool);

 Function: Get/set weather TSS2 is supported by CAGE evidence
 Returns : A boolean
 Args    : None or a boolean value

=cut

sub cage_evidence2
{
    my ($self, $bool) = @_;

    if ($bool) {
	$self->{-cage_evidence2} = $bool;
    }

    return $self->{-cage_evidence2}
}

=head2 ensembl_transcript_id1

 Title   : ensembl_transcript_id1
 Usage   : $id = $pp->ensembl_transcript_id1()
	   or $pp->ensembl_transcript_id1($id);

 Function: Get/set the Ensembl transcript ID which the TSS of this promoter
 	   is based on
 Returns : An Ensembl transcript ID
 Args    : None or an Ensembl transcript ID

=cut

sub ensembl_transcript_id1
{
    my ($self, $id) = @_;

    if ($id) {
	$self->{-ensembl_transcript_id1} = $id;
    }

    return $self->{-ensembl_transcript_id1}
}

=head2 ensembl_transcript_id2

 Title   : ensembl_transcript_id2
 Usage   : $id = $pp->ensembl_transcript_id2()
	   or $pp->ensembl_transcript_id2($id);

 Function: Get/set Ensembl transcript ID which the TSS of this promoter
 	   is based on
 Returns : An Ensembl transcript ID 
 Args    : None or an Ensembl transcript ID

=cut

sub ensembl_transcript_id2
{
    my ($self, $id) = @_;

    if ($id) {
	$self->{-ensembl_transcript_id2} = $id;
    }

    return $self->{-ensembl_transcript_id2}
}

=head2 gene_pair

 Title   : gene_pair
 Usage   : $gene_pair = $pp->gene_pair() or $pp->gene_pair($gene_pair);

 Function: Get/set the gene pair associated with this promoter pair
 Returns : A GenePair object
 Args    : None or a new GenePair object 

=cut

sub gene_pair
{
    my ($self, $pp) = @_;

    if ($pp) {
	if ($pp->isa("OPOSSUM::GenePair")) {
	    $self->{-gene_pair} = $pp;
	} else {
	    carp "not an OPOSSUM::GenePair";
	    return undef;
	}
    }
    return $self->{-gene_pair};
}

=head2 alignment

 Title   : alignment
 Usage   : $alignment = $pp->alignment() or $pp->alignment($alignment);

 Function: Get/set the alignment associated with this promoter pair
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
