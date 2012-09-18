=head1 NAME

OPOSSUM::DBBuildInfo - DBBuildInfo object (conserved_tf_sites DB record)

=head1 DESCRIPTION

A DBBuildInfo object models the (single) record contained in the db_build_info
table of the oPOSSUM DB. The DBBuildInfo object contains information about
how the oPOSSUM database was built, including the databases and software
versions which were used.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::DBBuildInfo;

use strict;

use Carp;

=head2 new

 Title   : new
 Usage   : $info = OPOSSUM::DBBuildInfo->new(
		    -build_date		=> '2006/11/26 17:23:06',
		    -species1		=> 'human',
		    -species2		=> 'mouse'
		    -ensembl_core_db1	=> 'homo_sapiens_core_39_36a',
		    -ensembl_core_db2	=> 'mus_musculus_core_39_36',
		    -ensembl_est_db1	=> 'homo_sapiens_otherfeatures_39_36a',
		    -ensembl_est_db2	=> 'mus_musculus_otherfeatures_39_36',
		    -orca_version	=> '1.0.5',
		    -ca_version		=> '1.0',
		    -tfbs_version	=> '0.5',
		    -upstream_bp	=> 10000,
		    -min_cr_length	=> 50,
		    -min_pwm_id		=> 8,
		    -min_tfbs_score	=> 0.70);

 Function: Construct a new DBBuildInfo object
 Returns : a new OPOSSUM::DBBuildInfo object

=cut

sub new
{
    my ($class, %args) = @_;

    my $self = bless {
		    %args
		}, ref $class || $class;

    return $self;
}

=head2 date

 Title   : date
 Usage   : $date = $dbbi->date() or $dbbi->date($date);

 Function: Get/set the DB build date.
 Returns : A string.
 Args    : None or a new date.

=cut

sub build_date
{
    my ($self, $build_date) = @_;

    if ($build_date) {
	$self->{-build_date} = $build_date;
    }

    return $self->{-build_date}
}

=head2 species1

 Title   : species1
 Usage   : $species1 = $dbbi->species1() or $dbbi->species1($species1);

 Function: Get/set the name of species 1.
 Returns : A string.
 Args    : None or a new species 1 name.

=cut

sub species1
{
    my ($self, $species) = @_;

    if ($species) {
	$self->{-species1} = $species;
    }

    return $self->{-species1};
}

=head2 species2

 Title   : species2
 Usage   : $species2 = $dbbi->species2() or $dbbi->species2($species2);

 Function: Get/set the name of species 2.
 Returns : A string.
 Args    : None or a new species 2 name.

=cut

sub species2
{
    my ($self, $species) = @_;

    if ($species) {
	$self->{-species2} = $species;
    }

    return $self->{-species2};
}

=head2 ensembl_core_db1

 Title   : ensembl_core_db1
 Usage   : $db_name = $dbbi->ensembl_core_db1()
 	   or $dbbi->ensembl_core_db1($db_name);

 Function: Get/set the name of the species 1 Ensembl core database.
 Returns : A string.
 Args    : None or a new species 1 Ensembl database name.

=cut

sub ensembl_core_db1
{
    my ($self, $ensembl_db) = @_;

    if ($ensembl_db) {
	$self->{-ensembl_core_db1} = $ensembl_db;
    }
    
    return $self->{-ensembl_core_db1};
}

=head2 ensembl_core_db2

 Title   : ensembl_core_db2
 Usage   : $db_name = $dbbi->ensembl_core_db2()
 	   or $dbbi->ensembl_core_db2($db_name);

 Function: Get/set the name of the species 2 Ensembl core database.
 Returns : A string.
 Args    : None or a new species 2 Ensembl database name.

=cut

sub ensembl_core_db2
{
    my ($self, $ensembl_db) = @_;

    if ($ensembl_db) {
	$self->{-ensembl_core_db2} = $ensembl_db;
    }
    
    return $self->{-ensembl_core_db2};
}

=head2 ensembl_est_db1

 Title   : ensembl_est_db1
 Usage   : $db_name = $dbbi->ensembl_est_db1()
 	   or $dbbi->ensembl_est_db1($db_name);

 Function: Get/set the name of the species 1 Ensembl EST database.
 Returns : A string.
 Args    : None or a new species 1 Ensembl database name.

=cut

sub ensembl_est_db1
{
    my ($self, $ensembl_db) = @_;

    if ($ensembl_db) {
	$self->{-ensembl_est_db1} = $ensembl_db;
    }

    return $self->{-ensembl_est_db1};
}

=head2 ensembl_est_db2

 Title   : ensembl_est_db2
 Usage   : $db_name = $dbbi->ensembl_est_db2()
 	   or $dbbi->ensembl_est_db2($db_name);

 Function: Get/set the name of the species 2 Ensembl EST database.
 Returns : A string.
 Args    : None or a new species 2 Ensembl database name.

=cut

sub ensembl_est_db2
{
    my ($self, $ensembl_db) = @_;

    if ($ensembl_db) {
	$self->{-ensembl_est_db2} = $ensembl_db;
    }

    return $self->{-ensembl_est_db2};
}

=head2 orca_version

 Title   : orca_version
 Usage   : $orca_version = $dbbi->orca_version()
	   or $dbbi->orca_version($version);

 Function: Get/set the version infomation for the ORCA alignment tool.
 Returns : A string.
 Args    : None or a new ORCA version string.

=cut

sub orca_version
{
    my ($self, $orca_version) = @_;

    if ($orca_version) {
	$self->{-orca_version} = $orca_version;
    }

    return $self->{-orca_version}
}

=head2 ca_version

 Title   : ca_version
 Usage   : $ca_version = $dbbi->ca_version()
	   or $dbbi->ca_version($version);

 Function: Get/set the version infomation for the ConservationAnalysis
 	   modules.
 Returns : A string.
 Args    : None or a new ConservationAnalysis version string.

=cut

sub ca_version
{
    my ($self, $ca_version) = @_;

    if ($ca_version) {
	$self->{-ca_version} = $ca_version;
    }

    return $self->{-ca_version}
}

=head2 tfbs_version

 Title   : tfbs_version
 Usage   : $tfbs_version = $dbbi->tfbs_version()
	   or $dbbi->tfbs_version($version);

 Function: Get/set the version infomation for the TFBS software package.
 Returns : A string.
 Args    : None or a new TFBS version string.

=cut

sub tfbs_version
{
    my ($self, $tfbs_version) = @_;

    if ($tfbs_version) {
	$self->{-tfbs_version} = $tfbs_version;
    }

    return $self->{-tfbs_version}
}

=head2 upstream_bp

 Title   : upstream_bp
 Usage   : $upstream_bp = $dbbi->upstream_bp()
 	   or $dbbi->upstream_bp($upstream_bp);

 Function: Get/set the amount of upstream bp used in the DB build.
 Returns : A string.
 Args    : None or a new upstream bp amount.

=cut

sub upstream_bp
{
    my ($self, $upstream_bp) = @_;

    if ($upstream_bp) {
	$self->{-upstream_bp} = $upstream_bp;
    }

    return $self->{-upstream_bp}
}

=head2 min_cr_length

 Title   : min_cr_length
 Usage   : $min_cr_length = $dbbi->min_cr_length()
 	   or $dbbi->min_cr_length($min_cr_length);

 Function: Get/set the minimum lenght of a conserved region to include
 	   in the conserved_regions table.
 Returns : A string.
 Args    : None or a new upstream bp amount.

=cut

sub min_cr_length
{
    my ($self, $min_cr_length) = @_;

    if ($min_cr_length) {
	$self->{-min_cr_length} = $min_cr_length;
    }

    return $self->{-min_cr_length}
}

=head2 min_pwm_ic

 Title   : min_pwm_ic
 Usage   : $min_pwm_ic = $dbbi->min_pwm_ic()
	   or $dbbi->min_pwm_ic($min_ic);

 Function: Get/set the position weight matrix minimum information content
 	   used when building the database.
 Returns : An integer.
 Args    : None or a new matrix minimum information content.

=cut

sub min_pwm_ic
{
    my ($self, $min_pwm_ic) = @_;

    if ($min_pwm_ic) {
	$self->{-min_pwm_ic} = $min_pwm_ic;
    }

    return $self->{-min_pwm_ic}
}

=head2 min_tfbs_score

 Title   : min_tfbs_score
 Usage   : $min_tfbs_score = $dbbi->min_tfbs_score()
	   or $dbbi->min_tfbs_score($min_score);

 Function: Get/set the minimum PSSM score threshold used when building
 	   the database.
 Returns : A float.
 Args    : None or a new minimum PSSM score threshold.

=cut

sub min_tfbs_score
{
    my ($self, $min_tfbs_score) = @_;

    if ($min_tfbs_score) {
	$self->{-min_tfbs_score} = $min_tfbs_score;
    }

    return $self->{-min_tfbs_score}
}

1;
