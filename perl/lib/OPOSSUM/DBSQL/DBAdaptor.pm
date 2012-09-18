=head1 NAME

0POSSUM::DBSQL::DBAdaptor

=head1 DESCRIPTION

This object represents a database. Once created you can retrieve database
adaptors specific to various database objects that allow the retrieval and
creation of objects from the database.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=cut

package OPOSSUM::DBSQL::DBAdaptor;

use vars qw(@ISA);
use strict;

use OPOSSUM::DBSQL::DBConnection;
use OPOSSUM::DBBuildInfo;

@ISA = qw(OPOSSUM::DBSQL::DBConnection);

=head2 new

 Title    : new
 Usage    : $db_adaptor = OPOSSUM::DBSQL::DBAdaptor->new(
				    -user	=> 'possum',
				    -host	=> 'localhost',
				    -dbname	=> 'OPOSSUM');
 Function : Construct a new DBAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::DBAdaptor object
 Args	  : All args passed to superclass.

=cut

sub new
{
    my ($class, @args) = @_;

    #call superclass constructor
    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 get_GenePairAdaptor

 Title    : get_GenePairAdaptor
 Usage    : $gpa = $db_adaptor->get_GenePairAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::GenePairAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::GenePairAdaptor object
 Args	  : None.

=cut

sub get_GenePairAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::GenePairAdaptor");
}

=head2 get_PromoterPairAdaptor

 Title    : get_PromoterPairAdaptor
 Usage    : $ppa = $db_adaptor->get_PromoterPairAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::PromoterPairAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::PromoterPairAdaptor object
 Args	  : None.

=cut

sub get_PromoterPairAdaptor
{
    my ($self) = @_;
 
    return $self->_get_adaptor("OPOSSUM::DBSQL::PromoterPairAdaptor");
}

=head2 get_PromoterPairSequencesAdaptor

 Title    : get_PromoterPairSequencesAdaptor
 Usage    : $ppsa = $db_adaptor->get_PromoterPairSequencesAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::PromoterPairSequencesAdaptor
 	    object.
 Returns  : A new OPOSSUM::DBSQL::PromoterPairSequencesAdaptor object
 Args	  : None.

=cut

sub get_PromoterPairSequencesAdaptor
{
    my ($self) = @_;
 
    return $self->_get_adaptor("OPOSSUM::DBSQL::PromoterPairSequencesAdaptor");
}

=head2 get_ConservedRegionAdaptor

 Title    : get_ConservedRegionAdaptor
 Usage    : $cra = $db_adaptor->get_ConservedRegionAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ConservedRegionAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::ConservedRegionAdaptor object
 Args	  : None.

=cut

sub get_ConservedRegionAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ConservedRegionAdaptor");
}

=head2 get_ConservedTFBSAdaptor

 Title    : get_ConservedTFBSAdaptor
 Usage    : $ctfsa = $db_adaptor->get_ConservedTFBSAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ConservedTFBSAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::ConservedTFBSAdaptor object
 Args	  : None.

=cut

sub get_ConservedTFBSAdaptor
{
    my ($self, $ext) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ConservedTFBSAdaptor", $ext);
}

=head2 get_TFInfoAdaptor

 Title    : get_TFInfoAdaptor
 Usage    : $ctia = $db_adaptor->get_TFInfoAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::TFInfoAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::TFInfoAdaptor object
 Args	  : None.

=cut

sub get_TFInfoAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::TFInfoAdaptor");
}

=head2 get_DBBuildInfoAdaptor

 Title    : get_DBBuildInfoAdaptor
 Usage    : $dbbia = $db_adaptor->get_DBBuildInfoAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::DBBuildInfoAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::DBBuildInfoAdaptor object
 Args	  : None.

=cut

sub get_DBBuildInfoAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::DBBuildInfoAdaptor");
}

=head2 get_TFBSCountAdaptor

 Title    : get_TFBSCountAdaptor
 Usage    : $tca = $db_adaptor->get_TFBSCountAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::TFBSCountAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::TFBSCountAdaptor object
 Args	  : None.

=cut

sub get_TFBSCountAdaptor
{
    my ($self, $ext) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::TFBSCountAdaptor", $ext);
}

=head2 get_AnalysisCountsAdaptor

 Title    : get_AnalysisCountsAdaptor
 Usage    : $aca = $db_adaptor->get_AnalysisCountsAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::Analysis::CountsAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::Analysis::CountsAdaptor object
 Args	  : None.

=cut

sub get_AnalysisCountsAdaptor
{
    my ($self, $ext) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::Analysis::CountsAdaptor", $ext);
}

=head2 get_ConservedRegionLengthAdaptor

 Title    : get_ConservedRegionLengthAdaptor
 Usage    : $crla = $db_adaptor->get_ConservedRegionLengthAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ConservedRegionLengthAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::ConservedRegionLengthAdaptor object
 Args	  : None.

=cut

sub get_ConservedRegionLengthAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ConservedRegionLengthAdaptor");
}

=head2 get_ConservationLevelAdaptor

 Title    : get_ConservationLevelAdaptor
 Usage    : $cla = $db_adaptor->get_ConservationLevelAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ConservationLevelAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::ConservationLevelAdaptor object
 Args	  : None.

=cut

sub get_ConservationLevelAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ConservationLevelAdaptor");
}

=head2 get_SearchRegionLevelAdaptor

 Title    : get_SearchRegionLevelAdaptor
 Usage    : $srla = $db_adaptor->get_SearchRegionLevelAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::SearchRegionLevelAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::SearchRegionLevelAdaptor object
 Args	  : None.

=cut

sub get_SearchRegionLevelAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::SearchRegionLevelAdaptor");
}

=head2 get_ThresholdLevelAdaptor

 Title    : get_ThresholdLevelAdaptor
 Usage    : $tla = $db_adaptor->get_ThresholdLevelAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ThresholdLevelAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::ThresholdLevelAdaptor object
 Args	  : None.

=cut

sub get_ThresholdLevelAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ThresholdLevelAdaptor");
}

=head2 get_ExternalGeneIDAdaptor

 Title    : get_ExternalGeneIDAdaptor
 Usage    : $xgia = $db_adaptor->get_ExternalGeneIDAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ExternalGeneIDAdaptor object.
 Returns  : A new OPOSSUM::DBSQL::ExternalGeneIDAdaptor object
 Args	  : None.

=cut

sub get_ExternalGeneIDAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ExternalGeneIDAdaptor");
}

=head2 get_ExternalGeneIDTypeAdaptor

 Title    : get_ExternalGeneIDTypeAdaptor
 Usage    : $xgita = $db_adaptor->get_ExternalGeneIDTypeAdaptor
 Function : Construct a new OPOSSUM::DBSQL::ExternalGeneIDTypeAdaptor
 Returns  : A new OPOSSUM::DBSQL::ExternalGeneIDTypeAdaptor
 Args	  : None.

=cut

sub get_ExternalGeneIDTypeAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ExternalGeneIDTypeAdaptor");
}

=head2 get_AlignmentAdaptor

 Title    : get_AlignmentAdaptor
 Usage    : $aa = $db_adaptor->get_AlignmentAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::AlignmentAdaptor
 	    object.
 Returns  : A new OPOSSUM::DBSQL::AlignmentAdaptor object
 Args	  : None.

=cut

sub get_AlignmentAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::AlignmentAdaptor");
}

=head2 get_ExonAdaptor

 Title    : get_ExonAdaptor
 Usage    : $ea = $db_adaptor->get_ExonAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ExonAdaptor
 	    object.
 Returns  : A new OPOSSUM::DBSQL::ExonAdaptor object
 Args	  : None.

=cut

sub get_ExonAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ExonAdaptor");
}

=head2 get_ConservationAnalysisAdaptor

 Title    : get_ConservationAnalysisAdaptor
 Usage    : $caa = $db_adaptor->get_ConservationAnalysisAdaptor();
 Function : Construct a new OPOSSUM::DBSQL::ConservationAnalysisAdaptor
 	    object.
 Returns  : A new OPOSSUM::DBSQL::ConservationAnalysisAdaptor object
 Args	  : None.

=cut

sub get_ConservationAnalysisAdaptor
{
    my ($self) = @_;
    
    return $self->_get_adaptor("OPOSSUM::DBSQL::ConservationAnalysisAdaptor");
}

sub deleteObj {
    my $self = shift;

    $self->SUPER::deleteObj;
}

1;
