=head1 NAME

OPOSSUM::TFInfoSet.pm - module to hold a set of TFInfo objects

=head1 DESCRIPTION

Implements a set of TFInfo objects

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::TFInfoSet;

use strict;

use OPOSSUM::TFInfo;

use Carp;

=head2 new

 Title    : new
 Usage    : $tfis = OPOSSUM::TFInfoSet->new();
 Function : Create a new OPOSSUM::TFInfoSet object.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args     : None.

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
		    _params	=> {},
		    _tfi_set	=> {} 
		}, ref $class || $class;

    return $self;
}

=head2 param

 Title    : param
 Usage    : $value = $tfis->param($param)
 	    or $tfis->param($param, $value);
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
 Usage    : $size = $tfis->size();
 Function : Return the size of the set (number of TFInfo objects)
 Returns  : An integer
 Args     : None

=cut

sub size
{
    return scalar keys %{$_[0]->{_tfi_set}} || 0;
}

=head2 tf_ids

 Title    : tf_ids
 Usage    : $ids = $tfis->tf_ids();
 Function : Return the IDs of the TFInfo objects in the set
 Returns  : A reference to a list of TF IDs
 Args     : None

=cut

sub tf_ids
{
    return keys %{$_[0]->{_tfi_set}};
}

=head2 get_tf_info

 Title    : get_tf_info
 Usage    : $tfi = $tfis->get_tf_info($id);
 Function : Return a TFInfo object from the set by it's ID
 Returns  : An OPOSSUM::TFInfo object
 Args     : ID of the TFInfo object

=cut

sub get_tf_info
{
    my ($self, $id) = @_;

    return $self->{_tfi_set}->{$id};
}

=head2 add_tf_info

 Title    : add_tf_info
 Usage    : $tfis->add_tf_info($tfi);
 Function : Add a new TFInfo object to the set
 Returns  : Nothing
 Args     : An OPOSSUM::TFInfo object

=cut

sub add_tf_info
{
    my ($self, $tfi) = @_;

    return if !$tfi;
    if (!ref $tfi || !$tfi->isa("OPOSSUM::TFInfo")) {
	carp "not an OPOSSUM::TFInfo object";
	return;
    }

    $self->{_tfi_set}->{$tfi->id} = $tfi;
}

=head2 subset

 Title    : subset
 Usage    : $subset = $tfis->subset($ids);
 Function : Return a subset of this set based on the provided IDs
 Returns  : An OPOSSUM::TFInfoSet object
 Args     : A ref to a list of TF IDs

=cut

sub subset
{
    my ($self, $ids) = @_;

    return if !$ids;

    my $subset = OPOSSUM::TFInfoSet->new();
    foreach my $id (@$ids) {
    	my $tfi = $self->get_tf_info($id);
	if ($tfi) {
	    $subset->add_tf_info(
	    		OPOSSUM::TFInfo->new(
					-id		=> $tfi->id,
					-external_id	=> $tfi->external_id,
					-name		=> $tfi->name,
					-phylum		=> $tfi->phylum,
					-class		=> $tfi->class,
					-ic		=> $tfi->ic,
					-width		=> $tfi->width
				    ));
	}
    }

    my @pkeys = $self->param;
    foreach my $pkey (@pkeys) {
    	$subset->param($pkey, $self->param($pkey));
    }

    return $subset;
}

1;
