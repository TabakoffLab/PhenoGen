=head1 NAME

OPOSSUM::DBSQL::ThresholdLevelAdaptor - Adaptor for MySQL queries to retrieve
and store PWM (PSSM) threshold levels.

=head1 SYNOPSIS

$tla = $db_adaptor->get_ThresholdLevelAdaptor();

=head1 DESCRIPTION

In order to facilitate fast retrieval of TFBS counts from the oPOSSUM database
several count sets were pre-computed using discrete values for PWM (PSSM)
thresholds, conservation levels, and upstream/downstream search regions.
The threshold_levels table of the oPOSSUM database stores information about
the discrete PWM (PSSM) threshold scores which were used, i.e. the minimum
matrix score used to determine a TFBS 'hit'. The records are stored with a level
number and the associated matrix score threshold used in the TFBS search.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::DBSQL::ThresholdLevelAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::ThresholdLevel;
use OPOSSUM::ThresholdLevelSet;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_levels

 Title    : fetch_levels
 Usage    : $levels = $tla->fetch_levels();
 Function : Fetch a list of all the PWM threshold levels in the DB.
 Returns  : A reference to a list of integer PWM threshold levels.
 Args	  : None.

=cut

sub fetch_levels
{
    my ($self) = @_;

    my $sql = qq{select threshold_level from threshold_levels
		    order by threshold_level};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching levels\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching levels\n" . $self->errstr;
	return;
    }

    my @levels;
    while (my ($level) = $sth->fetchrow_array) {
	push @levels, $level;
    }

    return @levels ? \@levels : undef;
}

=head2 fetch_threshold_levels

 Title    : fetch_threshold_levels
 Usage    : $tls = $tla->fetch_threshold_levels();
 Function : Fetch a list of all the threshold level objects in the DB.
 Returns  : A reference to a list of OPOSSUM::ThresholdLevel objects.
 Args	  : None.

=cut

sub fetch_threshold_levels
{
    my ($self) = @_;

    my $levels = OPOSSUM::ThresholdLevelSet->new();
    if (!$levels) {
    	carp "error creating new ThresholdLevelSet object\n";
	return;
    }

    my $sql = qq{select threshold_level, threshold from threshold_levels
    		    order by threshold_level};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching threshold levels\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching threshold levels\n" . $self->errstr;
	return;
    }

    while (my @row = $sth->fetchrow_array) {
	$levels->add_threshold_level(
		    OPOSSUM::ThresholdLevel->new(
					    -level		=> $row[0],
					    -threshold		=> $row[1]));
    }
    $sth->finish;

    return $levels;
}

=head2 fetch_by_level

 Title    : fetch_by_level
 Usage    : $tl = $tla->fetch_by_level($level);
 Function : Fetch a threshold level object by it's level number.
 Returns  : An OPOSSUM::ThresholdLevel object.
 Args	  : Integer level.

=cut

sub fetch_by_level
{
    my ($self, $level) = @_;

    my $sql = qq{select threshold from threshold_levels
		    where threshold_level = $level};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching threshold level $level\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching threshold level $level\n" . $self->errstr;
	return;
    }

    my $threshold;
    if (my @row = $sth->fetchrow_array) {
    	$threshold = $row[0];
    }
    $sth->finish;

    return $threshold;
}

1;
