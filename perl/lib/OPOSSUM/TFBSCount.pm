=head1 NAME

OPOSSUM::TFBSCount - TFBSCount object (tfbs_counts DB record)

=head1 DESCRIPTION

A TFBSCount object models a record retrieved from the tfbs_counts table of
the oPOSSUM DB. It contains the number of times a given TFBS was detected
for a given promoter pair at a given level of conservation, PWM score threshold
and search region.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

 Modified by Shannan Ho Sui on Dec 21, 2006 to account for db schema changes

=head1 METHODS

=cut

package OPOSSUM::TFBSCount;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $gptfc = OPOSSUM::TFBSCount->new(
				-gene_pair_id		=> $gpid,
				-tf_id			=> $tfid,
				-conservation_level	=> $clevel,
				-threshold_level	=> $tlevel,
				-search_region_level	=> $srlevel,
				-count			=> $count);

 Function: Construct a new TFBSCount object
 Returns : a new OPOSSUM::TFBSCount object

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
 Usage   : $id = $gptfc->gene_pair_id() or $gptfc->gene_pair_id($gpid);
 Function: Get/set the gene pair ID
 Returns : A gene pair ID
 Args    : Optionally a gene pair ID

=cut

sub gene_pair_id
{
    my ($self, $gpid) = @_;

    if (defined $gpid) {
	$self->{-gene_pair_id} = $gpid;
    }
    return $self->{-gene_pair_id};
}

=head2 tf_id

 Title   : tf_id
 Usage   : $id = $gptfc->tf_id() or $gptfc->tf_id($tfid);
 Function: Get/set the TF ID
 Returns : A TF ID
 Args    : Optionally a TF ID

=cut

sub tf_id
{
    my ($self, $tf_id) = @_;

    if (defined $tf_id) {
	$self->{-tf_id} = $tf_id;
    }
    return $self->{-tf_id};
}

=head2 conservation_level

 Title   : conservation_level
 Usage   : $clevel = $gptfc->conservation_level()
 	   or $gptfc->conservation_level($level);
 Function: Get/set the conservation level
 Returns : An integer conservation level
 Args    : Optionally an integer conservation level

=cut

sub conservation_level
{
    my ($self, $conservation_level) = @_;

    if (defined $conservation_level) {
	$self->{-conservation_level} = $conservation_level;
    }
    return $self->{-conservation_level};
}

=head2 threshold_level

 Title   : threshold_level
 Usage   : $tlevel = $gptfc->threshold_level()
 	   or $gptfc->threshold_level($level);
 Function: Get/set the threshold level
 Returns : An integer threshold level
 Args    : Optionally an integer threshold level

=cut

sub threshold_level
{
    my ($self, $threshold_level) = @_;

    if (defined $threshold_level) {
	$self->{-threshold_level} = $threshold_level;
    }
    return $self->{-threshold_level};
}

=head2 search_region_level

 Title   : search_region_level
 Usage   : $srlevel = $gptfc->search_region_level()
 	   or $gptfc->search_region_level($level);
 Function: Get/set the search region level
 Returns : An integer search region level
 Args    : Optionally an integer search region level

=cut

sub search_region_level
{
    my ($self, $search_region_level) = @_;

    if (defined $search_region_level) {
	$self->{-search_region_level} = $search_region_level;
    }
    return $self->{-search_region_level};
}

=head2 count

 Title   : count
 Usage   : $count = $gptfc->count()
 	   or $gptfc->search_count($count);
 Function: Get/set the TFBS count
 Returns : An integer TFBS count
 Args    : Optionally an integer TFBS count

=cut

sub count
{
    my ($self, $count) = @_;

    if (defined $count) {
	$self->{-count} = $count;
    }
    return $self->{-count};
}

1;
