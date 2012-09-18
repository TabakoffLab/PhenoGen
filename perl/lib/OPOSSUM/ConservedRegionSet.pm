=head1 NAME

ConservedRegionSet.pm - module to hold a set of ConservedRegion objects

=head1 DESCRIPTION

Implements a set of ConservedRegion objects

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::ConservedRegionSet;

use strict;

use OPOSSUM::ConservedRegion;
use Bio::SeqFeature::Generic;
use Bio::SeqFeature::FeaturePair;

use Carp;

=head2 new

 Title    : new
 Usage    : $crs = OPOSSUM::ConservedRegionSet->new();
 Function : Create a new OPOSSUM::ConservedRegionSet object.
 Returns  : An OPOSSUM::ConservedRegionSet object.
 Args     : None

=cut

sub new
{
    my ($class) = @_;

    my $self = bless {
		    _params		=> {},
		    _region_array	=> []
		}, ref $class || $class;

    return $self;
}

=head2 param

 Title    : param
 Usage    : $value = $crs->param($param)
 	    or $crs->param($param, $value);
 Function : Get/set the value of a parameter
 Returns  : Value of the named parameter
 Args     : [1] name of a parameter
 	    [2] on set, the value of the parameter

=cut

sub param
{
    my ($self, $param, $value) = @_;

    if ($param) {
	if (defined $value) {
	    $self->{_params}->{$param} = $value;
	}
	return $self->{_params}->{$param};
    }
    return keys %{$self->{_params}};
}

=head2 size

 Title    : size
 Usage    : $size = $crs->size();
 Function : Return the size of the set (number of ConservedRegion objects)
 Returns  : An integer
 Args     : None

=cut

sub size
{
    my $self = shift;

    return $self->{_region_array} ? scalar @{$self->{_region_array}} : 0;
}

=head2 total_length

 Title    : total_length
 Usage    : $length = $crs->total_length();
 Function : Alias for total_length1
 Returns  : An integer
 Args     : None

=cut

sub total_length
{
    my $self = shift;

    return $self->total_length1;
}

=head2 total_length1

 Title    : total_length1
 Usage    : $length = $crs->total_length1();
 Function : Return the total length of the conserved regions in the set
	    (based on species 1 start/ends).
 Returns  : An integer
 Args     : None

=cut

sub total_length1
{
    my $self = shift;

    my $length = 0;
    foreach my $cr (@{$self->{_region_array}}) {
	$length += $cr->length1;
    }

    return $length;
}

=head2 total_length2

 Title    : total_length2
 Usage    : $length = $crs->total_length2();
 Function : Return the total length of the conserved regions in the set
	    (based on species 2 start/ends).
 Returns  : An integer
 Args     : None

=cut

sub total_length2
{
    my $self = shift;

    my $length = 0;
    foreach my $cr (@{$self->{_region_array}}) {
	$length += $cr->length2;
    }

    return $length;
}

=head2 conserved_regions

 Title    : conserved_regions
 Usage    : $regions = $crs->conserved_regions($sort_by);
 Function : Return the (optionally sorted) list of conserved regions
 	    in the set
 Returns  : A listref of ConservedRegion objects
 Args     : [1] Optionally a ConservedRegion field nane to sort by

=cut

sub conserved_regions
{
    my ($self, $sort_by) = @_;

    my @crs;
    if ($sort_by) {
	if ($sort_by eq 'start' || $sort_by eq 'start1') {
	    @crs = sort {$a->start1 <=> $b->start1
			    || $a->end1 <=> $b->end1
	    		} @{$self->{_region_array}};
	} elsif ($sort_by eq 'start2') {
	    @crs = sort {$a->start2 <=> $b->start2
			    || $a->end2 <=> $b->end2
	    		} @{$self->{_region_array}};
	} elsif ($sort_by eq 'end' || $sort_by eq 'end1') {
	    @crs = sort {$a->end1 <=> $b->end1
			    || $a->start1 <=> $b->start1
	    		} @{$self->{_region_array}};
	} elsif ($sort_by eq 'end2') {
	    @crs = sort {$a->end2 <=> $b->end2
			    || $a->start2 <=> $b->start2
	    		} @{$self->{_region_array}};
	} elsif ($sort_by eq 'conservation') {
	    @crs = sort {$a->conservation <=> $b->conservation
			    || $a->start1 <=> $b->start1
	    		} @{$self->{_region_array}};
	} else {
	    carp "unrecognized sort field";
	}
    }

    @crs = @{$self->{_region_array}};

    return @crs ? \@crs : undef;
}

=head2 add_conserved_region

 Title    : add_conserved_region
 Usage    : $crs->add_conserved_region($cr);
 Function : Add a new ConservedRegion object to the set
 Returns  : Nothing
 Args     : An OPOSSUM::ConservedRegion object

=cut

sub add_conserved_region
{
    my ($self, $cr) = @_;

    return if !$cr;
    if (!ref $cr || !$cr->isa("OPOSSUM::ConservedRegion")) {
	carp "conserved region is not an OPOSSUM::ConservedRegion object";
	return;
    }

    my $level = $self->param('conservation_level');
    if ($level && $cr->level != $level) {
    	carp "region conservation level does not match set";
    	return;
    }

    push @{$self->{_region_array}}, $cr;
}

=head2 as_feature_pairs

 Title    : as_feature_pairs
 Usage    : $fps = $crs->as_feature_pairs($sort_by);
 Function : Return the conserved region set as 
	    Bio::SeqFeature::FeaturePairs
 Returns  : A reference to a list of Bio::SeqFeature::FeaturePair objects
 Args     : [1] Optionally a ConservedRegion field nane to sort by

=cut

sub as_feature_pairs
{
    my ($self, $sort_by) = @_;

    my @fps;
    foreach my $cr ($self->conserved_regions($sort_by)) {
	my $feature1 = Bio::SeqFeature::Generic->new(
			-source_tag     => "oPOSSUM",
			-start		=> $cr->start1,
			-end		=> $cr->end1,
			-score          => $cr->conservation);

	my $feature2 = Bio::SeqFeature::Generic->new(
			-source_tag     => "oPOSSUM",
			-start		=> $cr->start2,
			-end		=> $cr->end2,
			-score          => $cr->conservation);

    	push @fps, Bio::SeqFeature::FeaturePair->new(
			-feature1	=> $feature1,
			-feature2	=> $feature2);
    	
    }

    return @fps ? \@fps : undef;
}

1;
