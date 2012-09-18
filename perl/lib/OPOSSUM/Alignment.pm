=head1 NAME

OPOSSUM::Alignment - Alignment object (alignment DB record)

=head1 DESCRIPTION

An Alignment object models a record retrieved from the aligment table
of the oPOSSUM DB. It contains the unaligned raw and masked sequences of
each species as well as the aligned (masked and gapped) sequences. It also
stores the positional information of the sequences.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::Alignment;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $aln = OPOSSUM::Alignment->new(
			    -gene_pair_id	=> 1,
			    -start1		=> 106583104,
			    -start2		=> 53051888,
			    -end1		=> 106740339,
			    -end2		=> 53190992,
			    -strand1		=> 1,
			    -strand2		=> -1,
			    -seq1		=> 'ACTGCTGAAAA...',
			    -seq2		=> '...TTTTCAGAGT',
			    -masked_seq1	=> 'ACTGCTGANNN...',
			    -masked_seq2	=> '...NNNTCAGAGT',
			    -aligned_seq1	=> 'ACTGCTGANNN...',
			    -aligned_seq2	=> 'ACT_CTGANNN...');

 Function: Construct a new Alignment object
 Returns : a new OPOSSUM::Alignment object

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
		    %args
		}, ref $class || $class;

    return $self;
}

#
# Not used. Since there is a 1-to-1 relationship between gene_pairs and
# alignments this is redundant. Use gene_pair_id as primary id.
#
#=head2 id
#
# Title   : id
# Usage   : $id = $aln->id() or $aln->id('123');
#
# Function: Get/set the ID of the Alignment. This should be a unique
# 	   identifier for this object within the implementation. If
#	   the Alignment object was read from the oPOSSUM database,
#	   this should be set to the value in the alignment_id column.
# Returns : A numeric ID
# Args    : None or a numeric ID
#
#=cut
#
#sub id
#{
#    my ($self, $id) = @_;
#
#    if ($id) {
#	$self->{-id} = $id;
#    }
#    return $self->{-id};
#}

=head2 gene_pair_id

 Title   : gene_pair_id
 Usage   : $gene_pair_id = $aln->gene_pair_id()
 	   or $aln->gene_pair_id('123');

 Function: Get/set the ID of the GenePair associated with this Alignment.
 Returns : A numeric GenePair ID
 Args    : None or a numeric GenePair ID

=cut

sub gene_pair_id
{
    my ($self, $gene_pair_id) = @_;

    if ($gene_pair_id) {
	$self->{-gene_pair_id} = $gene_pair_id;
    }
    return $self->{-gene_pair_id};
}

=head2 chr1

 Title   : chr1
 Usage   : $chr = $aln->chr1() or $aln->chr1('9');

 Function: Get/set the species 1 chromosome name of the aligned sequences.
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
 Usage   : $chr = $aln->chr2() or $aln->chr2('4');

 Function: Get/set the species 2 chromosome name of the aligned sequences.
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
 Usage   : $strand = $aln->strand1() or $aln->strand1(1);

 Function: Get/set the species 1 strand. This is NOT the strand of
 	   the species 1 gene from which this sequence was obtained.
	   It indicates which strand the first sequence used in the
	   alignment falls on. In oPOSSUM this is ALWAYS 1.
 Returns : 1 or -1 (should always be one within the oPOSSUM system)
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
 Usage   : $strand = $aln->strand2() or $aln->strand2(-1);

 Function: Get/set the species 2 strand. This is NOT the strand of
 	   the species 2 gene from which this sequence was obtained.
	   This actually indicates the strand of the sequence within the
	   alignment. If it is -1 it indicates that the aligment process
	   reverse complemented the input sequence to create the correct
	   alignment.
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
 Usage   : $start = $aln->start1() or $aln->start1($start);

 Function: Get/set the species 1 alignment start position
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
 Usage   : $start = $aln->start2() or $aln->start2($start);

 Function: Get/set the species 2 alignment start position
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
 Usage   : $end = $aln->end1() or $aln->end1($end);

 Function: Get/set the species 1 alignment end position
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

=head2 truncated1

 Title   : truncated1
 Usage   : $truncated = $aln->truncated1() or $aln->truncated1($truncated);

 Function: Get/set the flag indicating that the upstream portion of the
 	   alignment was truncated due to an upstream gene for the species 1
	   sequence
 Returns : An boolean
 Args    : None or a new truncated flag 

=cut

sub truncated1
{
    my ($self, $truncated) = @_;

    if ($truncated) {
	$self->{-truncated1} = $truncated;
    }

    return $self->{-truncated1};
}

=head2 end2

 Title   : end2
 Usage   : $end = $aln->end2() or $aln->end2($end);

 Function: Get/set the species 2 alignment end position
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

=head2 truncated2

 Title   : truncated2
 Usage   : $truncated = $aln->truncated2() or $aln->truncated2($truncated);

 Function: Get/set the flag indicating that the upstream portion of the
 	   alignment was truncated due to an upstream gene for the species 1
	   sequence
 Returns : An boolean
 Args    : None or a new truncated flag 

=cut

sub truncated2
{
    my ($self, $truncated) = @_;

    if ($truncated) {
	$self->{-truncated2} = $truncated;
    }

    return $self->{-truncated2};
}

=head2 seq1

 Title   : seq1
 Usage   : $seq = $aln->seq1() or $aln->seq1($seq);

 Function: Get/set the species 1 sequence
 Returns : The species 1 sequence
 Args    : None or a new species 1 sequence

=cut

sub seq1
{
    my ($self, $seq) = @_;

    if ($seq) {
	$self->{-seq1} = $seq;
    }

    return $self->{-seq1};
}

=head2 seq2

 Title   : seq2
 Usage   : $seq = $aln->seq2() or $aln->seq2($seq2);

 Function: Get/set the species 2 sequence
 Returns : The species 2 sequence
 Args    : None or a new species 2 sequence

=cut

sub seq2
{
    my ($self, $seq) = @_;

    if ($seq) {
	$self->{-seq2} = $seq;
    }
    return $self->{-seq2};
}

=head2 masked_seq1

 Title   : masked_seq1
 Usage   : $seq = $aln->masked_seq1() or $aln->masked_seq1($seq);

 Function: Get/set the masked species 1 sequence
 Returns : The species 1 masked sequence
 Args    : None or a new species 1 masked sequence

=cut

sub masked_seq1
{
    my ($self, $seq) = @_;

    if ($seq) {
	$self->{-masked_seq1} = $seq;
    }

    return $self->{-masked_seq1};
}

=head2 masked_seq2

 Title   : masked_seq2
 Usage   : $seq = $aln->masked_seq2() or $aln->masked_seq2($seq);

 Function: Get/set the masked species 2 sequence
 Returns : The species 2 masked sequence
 Args    : None or a new species 2 masked sequence

=cut

sub masked_seq2
{
    my ($self, $seq) = @_;

    if ($seq) {
	$self->{-masked_seq2} = $seq;
    }

    return $self->{-masked_seq2};
}

=head2 aligned_seq1

 Title   : aligned_seq1
 Usage   : $seq = $aln->aligned_seq1() or $aln->aligned_seq1($seq);

 Function: Get/set the aligned species 1 sequence
 Returns : The species 1 aligned sequence
 Args    : None or a new species 1 aligned sequence

=cut

sub aligned_seq1
{
    my ($self, $seq) = @_;

    if ($seq) {
	$self->{-aligned_seq1} = $seq;
    }

    return $self->{-aligned_seq1};
}

=head2 aligned_seq2

 Title   : aligned_seq2
 Usage   : $seq = $aln->aligned_seq2() or $aln->aligned_seq2($seq);

 Function: Get/set the aligned species 2 sequence
 Returns : The species 2 aligned sequence
 Args    : None or a new species 2 aligned sequence

=cut

sub aligned_seq2
{
    my ($self, $seq) = @_;

    if ($seq) {
	$self->{-aligned_seq2} = $seq;
    }

    return $self->{-aligned_seq2};
}

=head2 gene_pair

 Title   : gene_pair
 Usage   : $gene_pair = $aln->gene_pair()
 	   or $aln->gene_pair($gene_pair);

 Function: Get/set the GenePair object associated with this Aligment
 Returns : A GenePair object
 Args    : None or a new GenePair object 

=cut

sub gene_pair
{
    my ($self, $gp) = @_;

    if ($gp) {
	if ($gp->isa("OPOSSUM::GenePair")) {
	    $self->{-gene_pair} = $gp;
	} else {
	    carp "not a OPOSSUM::GenePair";
	    return undef;
	}
    }
    return $self->{-gene_pair};
}

1;
