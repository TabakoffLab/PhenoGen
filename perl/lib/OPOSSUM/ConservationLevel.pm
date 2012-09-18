=head1 NAME

OPOSSUM::ConservationLevel - ConservationLevel object (conservation_levels
DB record)

=head1 DESCRIPTION

A ConservationLevel object models a record retrieved from the
conservation_levels table of the oPOSSUM DB. This table stores the various
levels at which conserved regions were computed, stored and searched for
TFBSs within the region around the TSSs of the promoter pairs. Conservation
was computed at different levels. Each level corresponds to the top percentile
of all percentage identity windows within the TSS search region with a given
absolute minimum percentage identity cutoff.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::ConservationLevel;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $cl = OPOSSUM::ConservationLevel->new(
			    -level		=> 1,
			    -top_percentile	=> 10,
			    -min_percentage	=> 70);

 Function: Construct a new ConservationLevel object
 Returns : a new OPOSSUM::ConservationLevel object

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
		    %args
		}, ref $class || $class;

    return $self;
}

=head2 level

 Title   : level
 Usage   : $level = $cl->level() or $cl->level(1);

 Function: Get/set the conservation level.
 Returns : An integer.
 Args    : None or an integer.

=cut

sub level
{
    my ($self, $level) = @_;

    if ($level) {
	$self->{-level} = $level;
    }

    return $self->{-level}
}

=head2 top_percentile

 Title   : top_percentile
 Usage   : $tp = $cl->top_percentile() or $cl->top_percentile(1);

 Function: Get/set the top percentile of conserved regions associated with
 	   this conservation level.
 Returns : An real number.
 Args    : None or a real number.

=cut

sub top_percentile
{
    my ($self, $tp) = @_;

    if ($tp) {
	$self->{-top_percentile} = $tp;
    }

    return $self->{-top_percentile}
}

=head2 min_percentage

 Title   : min_percentage
 Usage   : $mp = $cl->min_percentage() or $cl->min_percentage(1);

 Function: Get/set the minimum percentage identity of the conserved regions
	   associated with this conservation level.
 Returns : An real number.
 Args    : None or a real number.

=cut

sub min_percentage
{
    my ($self, $mp) = @_;

    if ($mp) {
	$self->{-min_percentage} = $mp;
    }

    return $self->{-min_percentage}
}

1;
