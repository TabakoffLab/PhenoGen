=head1 NAME

OPOSSUM::TFInfo - TFInfo object (tf_info DB record)

=head1 DESCRIPTION

A TFInfo object models a record retrieved from the tf_info table of the
oPOSSUM DB. It stores information about transcription factor binding site
profiles.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::TFInfo;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $ti = OPOSSUM::TFInfo->new(
			    -id			=> '1',
			    -external_db	=> 'JASPAR_CORE',
			    -external_id	=> 'MA0001',
			    -name		=> 'AGL3',
			    -class		=> 'MADS',
			    -phylum		=> 'plant',
			    -width		=> 10,
			    -ic			=> 10.5882);

 Function: Construct a new TFInfo object
 Returns : a new OPOSSUM::TFInfo object

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
 Usage   : $id = $ti->id() or $ti->id($id);

 Function: Get/set the ID of the TFBS profile. This should be a unique
 	   identifier for this object within the implementation. If
	   the GenePair object was read from the oPOSSUM database,
	   this should be set to the value in the tf_id column.
 Returns : A string
 Args    : None or an id string

=cut

sub id
{
    my ($self, $id) = @_;

    if (defined $id) {
	$self->{-id} = $id;
    }
    return $self->{-id};
}

=head2 name

 Title   : name
 Usage   : $name = $ti->name() or $ti->name($name);

 Function: Get/set the name of the TFBS profile.
 Returns : A string
 Args    : None or an id string

=cut

sub name
{
    my ($self, $name) = @_;

    if (defined $name) {
	$self->{-name} = $name;
    }
    return $self->{-name};
}

=head2 external_id

 Title   : external_id
 Usage   : $id = $ti->external_id() or $ti->external_id($id);

 Function: Get/set the external ID of the TFBS profile. Within the context
 	   of the oPOSSUM database this is the unique ID of this profile
	   in the originating DB (i.e. JASPAR2).
 Returns : An external ID string
 Args    : None or an ID string

=cut

sub external_id
{
    my ($self, $external_id) = @_;

    if (defined $external_id) {
	$self->{-external_id} = $external_id;
    }
    return $self->{-external_id};
}

=head2 external_db

 Title   : external_db
 Usage   : $db = $ti->external_db() or $ti->external_db($db);

 Function: Get/set the external DB name of the TFBS profile
	   (i.e. JASPAR_CORE).
 Returns : A DB name
 Args    : None or a DB name

=cut

sub external_db
{
    my ($self, $db_name) = @_;

    if (defined $db_name) {
	$self->{-external_db} = $db_name;
    }
    return $self->{-external_db};
}

=head2 class

 Title   : class
 Usage   : $class = $ti->class() or $ti->class($class);

 Function: Get/set the class of the TFBS profile.
 Returns : A string
 Args    : None or a string

=cut

sub class
{
    my ($self, $class) = @_;

    if (defined $class) {
	$self->{-class} = $class;
    }
    return $self->{-class};
}

=head2 phylum

 Title   : phylum
 Usage   : $phylum = $ti->phylum() or $ti->phylum($phylum);

 Function: Get/set the phylum of the TFBS profile. This might be more
 	   accurately called taxonomic supergroup.
 Returns : A string
 Args    : None or a string

=cut

sub phylum
{
    my ($self, $phylum) = @_;

    if (defined $phylum) {
	$self->{-phylum} = $phylum;
    }
    return $self->{-phylum};
}

=head2 width

 Title   : width
 Usage   : $width = $ti->width() or $ti->width($width);

 Function: Get/set the width of the TFBS profile in nucleotides.
 Returns : An integer
 Args    : None or an integer

=cut

sub width
{
    my ($self, $width) = @_;

    if (defined $width) {
	$self->{-width} = $width;
    }
    return $self->{-width};
}

=head2 ic

 Title   : ic
 Usage   : $ic = $ti->ic() or $ti->ic($ic);

 Function: Get/set the information content of the TFBS profile. This is also
 	   known as specificity.
 Returns : A float
 Args    : None or a float

=cut

sub ic
{
    my ($self, $ic) = @_;

    if (defined $ic) {
	$self->{-ic} = $ic;
    }
    return $self->{-ic};
}

1;
