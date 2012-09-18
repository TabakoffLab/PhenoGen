=head1 NAME

OPOSSUM::ConservedRegion - ConservedRegion object (conserved_regions DB record)

=head1 DESCRIPTION

A ConservedRegion object models a record retrieved from the conserved_regions
table of the oPOSSUM DB. The ConservedRegion object contains the start and
end positions of the conserved region on the promoter pair sequences for
a given level of conservation.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::ConservedRegion;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $cr = OPOSSUM::ConservedRegion->new(
			    -gene_pair_id	=> 1,
			    -level		=> 1,
			    -start1		=> 1565,
			    -end1		=> 1697,
			    -rel_start1		=> 1,
			    -rel_end1		=> 100,
			    -start2		=> 2235,
			    -end2		=> 2430,
			    -rel_start2		=> 23,
			    -rel_end2		=> 145,
			    -conservation	=> 0.76);

 Function: Construct a new ConservedRegion object
 Returns : a new OPOSSUM::ConservedRegion object

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
 Usage   : $gpid = $cr->gene_pair_id() or $cr->gene_pair_id($gpid);

 Function: Get/set the ID of the GenePair that this conserved region
 	   is associated with.
 Returns : An integer GenePair ID.
 Args    : None or an OPOSSUM::GenePair ID.

=cut

sub gene_pair_id
{
    my ($self, $gpid) = @_;

    if (defined $gpid) {
	$self->{-gene_pair_id} = $gpid;
    }

    return $self->{-gene_pair_id};
}

=head2 level

 Title   : level
 Usage   : $level = $cr->level() or $cr->level($level)

 Function: Get/set the conservation level
 Args	 : None or an integer conservation level
 Returns : Integer conservation level

=cut

sub level
{
    my ($self, $level) = @_;

    if (defined $level) {
	$self->{-level} = $level;
    }

    return $self->{-level};
}

=head2 conservation_level

 Title   : conservation_level
 Usage   : synonymous with level

=cut

sub conservation_level
{
    my ($self, $level) = @_;

    return $self->level($level);
}

=head2 start1

 Title   : start1
 Usage   : $start = $cr->start1() or $cr->start1($start_pos);

 Function: Get/set the start position of the conserved region on the
 	   species 1 sequence.
 Returns : An integer.
 Args    : None or an integer start position.

=cut

sub start1
{
    my ($self, $start) = @_;

    if (defined $start) {
    	$self->{-start1} = $start;
    }

    return $self->{-start1};
}

=head2 start2

 Title   : start2
 Usage   : $start = $cr->start2() or $cr->start2($start_pos);

 Function: Get/set the start position of the conserved region on the
 	   species 2 sequence.
 Returns : An integer.
 Args    : None or a start position.

=cut

sub start2
{
    my ($self, $start) = @_;

    if (defined $start) {
    	$self->{-start2} = $start;
    }

    return $self->{-start2};
}

=head2 end1

 Title   : end1
 Usage   : $end = $cr->end1() or $cr->end1($end_pos);

 Function: Get/set the end position of the conserved region on the
 	   species 1 sequence.
 Returns : An integer.
 Args    : None or an integer end position.

=cut

sub end1
{
    my ($self, $end) = @_;

    if (defined $end) {
    	$self->{-end1} = $end;
    }

    return $self->{-end1};
}

=head2 end2

 Title   : end2
 Usage   : $end = $cr->end2() or $cr->end2($end_pos);

 Function: Get/set the end position of the conserved region on the
 	   species 2 sequence.
 Returns : An integer.
 Args    : None or an integer end position.

=cut

sub end2
{
    my ($self, $end) = @_;

    if (defined $end) {
    	$self->{-end2} = $end;
    }

    return $self->{-end2};
}

=head2 rel_start1

 Title   : rel_start1
 Usage   : $rel_start = $cr->rel_start1()
 	   or $cr->rel_start1($rel_start_pos);

 Function: Get/set the relative start position of the conserved region on
 	   the species 1 sequence.
 Returns : An integer.
 Args    : None or an integer relative start position.

=cut

sub rel_start1
{
    my ($self, $rel_start) = @_;

    if (defined $rel_start) {
    	$self->{-rel_start1} = $rel_start;
    }

    return $self->{-rel_start1};
}

=head2 rel_start2

 Title   : rel_start2
 Usage   : $rel_start = $cr->rel_start2()
	   or $cr->rel_start2($rel_start_pos);

 Function: Get/set the relative start position of the conserved region on
 	   the species 2 sequence.
 Returns : An integer.
 Args    : None or a relative start position.

=cut

sub rel_start2
{
    my ($self, $rel_start) = @_;

    if (defined $rel_start) {
    	$self->{-rel_start2} = $rel_start;
    }

    return $self->{-rel_start2};
}

=head2 rel_end1

 Title   : rel_end1
 Usage   : $rel_end = $cr->rel_end1() or $cr->rel_end1($rel_end_pos);

 Function: Get/set the relative end position of the conserved region on the
 	   species 1 sequence.
 Returns : An integer.
 Args    : None or an integer relative end position.

=cut

sub rel_end1
{
    my ($self, $rel_end) = @_;

    if (defined $rel_end) {
    	$self->{-rel_end1} = $rel_end;
    }

    return $self->{-rel_end1};
}

=head2 rel_end2

 Title   : rel_end2
 Usage   : $rel_end = $cr->rel_end2() or $cr->rel_end2($rel_end_pos);

 Function: Get/set the relative end position of the conserved region on the
   	   species 2 sequence.
 Returns : An integer.
 Args    : None or an integer relative end position.

=cut

sub rel_end2
{
    my ($self, $rel_end) = @_;

    if (defined $rel_end) {
    	$self->{-rel_end2} = $rel_end;
    }

    return $self->{-rel_end2};
}

=head2 conservation

 Title   : conservation
 Usage   : $conservation = $cr->conservation()
	   or $cr->conservation($conservation);

 Function: Get/set the conservation score (percent identity) of the
 	   conserved region.
 Returns : A real number.
 Args    : None or a conservation score (percent identity).

=cut

sub conservation
{
    my ($self, $conservation) = @_;

    if (defined $conservation) {
	$self->{-conservation} = $conservation;
    }

    return $self->{-conservation};
}

=head2 length

 Title   : length
 Usage   : $length = $cr->length();

 Function: Alias for length1
 Returns : An integer.
 Args    : None.

=cut

sub length
{
    my $self = shift;

    return $self->length1;
}

=head2 length1

 Title   : length1
 Usage   : $length = $cr->length1();

 Function: Get the length of the conserved region on the species 1
 	   promoter pair sequence.
 Returns : An integer.
 Args    : None.

=cut

sub length1
{
    my $self = shift;

    return $self->end1 - $self->start1 + 1;
}

=head2 length2

 Title   : length2
 Usage   : $length = $cr->length2();

 Function: Get the length of the conserved region on the species 2
 	   promoter pair sequence.
 Returns : An integer.
 Args    : None.

=cut

sub length2
{
    my $self = shift;

    return $self->end2 - $self->start2 + 1;
}

=head2 gene_pair

 Title   : gene_pair
 Usage   : $gp = $cr->gene_pair() or $cr->gene_pair($gp);

 Function: Get/set the GenePair that this conserved region is associated
 	   with.
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
 Usage   : $alignment = $cr->alignment() or $cr->alignment($alignment);

 Function: Get/set the alignment associated with this conserved region
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
