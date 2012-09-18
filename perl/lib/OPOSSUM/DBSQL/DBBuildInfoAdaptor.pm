=head1 NAME

OPOSSUM::DBSQL::DBBuildInfoAdaptor - Adaptor for MySQL queries to retrieve
and store DB build information.

=head1 SYNOPSIS

$cla = $db_adaptor->get_DBBuildInfoAdaptor();

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::DBSQL::DBBuildInfoAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::DBBuildInfo;

use vars qw(@ISA);
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);


=head2 new

 Title    : new
 Usage    : $dbbia = OPOSSUM::DBSQL::DBBuildInfoAdaptor->new(@args);
 Function : Create a new DBBuildInfoAdaptor.
 Returns  : A new OPOSSUM::DBSQL::DBBuildInfoAdaptor object.
 Args	  : An OPOSSUM::DBSQL::DBConnection object.

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_db_build_info

 Title    : fetch_db_build_info
 Usage    : $db_info = $cla->fetch_db_build_info();
 Function : Fetch the database build information.
 Returns  : An OPOSSUM::DBBuildInfo object.
 Args	  : None.

=cut

sub fetch_db_build_info
{
    my $self = shift;

    my $sql = qq{
		    select date_format(build_date, '%Y/%m/%d %T'),
			species1,
			species2,
			ensembl_core_db1,
			ensembl_core_db2,
			ensembl_est_db1,
			ensembl_est_db2,
			orca_version,
			ca_version,
			tfbs_version,
			upstream_bp,
			min_cr_length,
			min_pwm_ic,
			min_tfbs_score
		    from db_build_info};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error reading oPOSSUM DB build info\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error reading oPOSSUM DB build info\n" . $self->errstr;
	return;
    }
    my @row = $sth->fetchrow_array;
    $sth->finish;
    if (!@row) {
	carp "error reading oPOSSUM DB build info\n" . $self->errstr;
	return;
    }

    my $db_build_info = OPOSSUM::DBBuildInfo->new(
			    -build_date		=> $row[0],
			    -species1		=> $row[1],
			    -species2		=> $row[2],
			    -ensembl_core_db1	=> $row[3],
			    -ensembl_core_db2	=> $row[4],
			    -ensembl_est_db1	=> $row[5],
			    -ensembl_est_db2	=> $row[6],
			    -orca_version	=> $row[7],
			    -ca_version		=> $row[8],
			    -tfbs_version	=> $row[9],
			    -upstream_bp	=> $row[10],
			    -min_cr_length	=> $row[11],
			    -min_pwm_ic		=> $row[12],
			    -min_tfbs_score	=> $row[13]);

    return $db_build_info;
}

1;
