=head1 NAME

OPOSSUM::DBSQL::BaseAdaptor - Base Adaptor for DBSQL adaptors

=head1 DESCRITION

Base class for Adaptors in the oPOSSUM DBSQL.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::BaseAdaptor;

use strict;

use Carp;

=head2 new

 Title    : new
 Usage    : $adaptor = OPOSSUM::DBSQL::BaseAdaptor->new($dbobj);
 Function : Construct a new BaseAdaptor object. The intent is that this
 	    constructor would be called by an inherited superclass either
	    automatically or through $self->SUPER::new in an overridden
	    new method.
 Returns  : a new OPOSSUM::DBSQL::BaseAdaptor object
 Args	  : an OPOSSUM::DBSQL::DBConnection object

=cut

sub new
{
    my ($class, $dbobj) = @_;

    if (!defined $dbobj || !ref $dbobj) {
	carp "No DB object for new adaptor";
	return;
    }

    my $self = bless {
		    -db => $dbobj
		}, ref $class || $class;

    return $self;
}

=head2 prepare

 Title    : prepare
 Usage    : $sth = $adaptor->prepare($sql_statement);
 Function : Return a DBI statement handle from the adaptor.
 Returns  : A DBI statement handle.
 Args     : An SQL statement to be prepared by this adaptor's database.

=cut

sub prepare
{
    my ($self, $string) = @_;

    return $self->db->prepare($string);
}

=head2 errstr

 Title    : errstr
 Usage    : $err = $adaptor->errstr();
 Function : Return the last DBI error string.
 Returns  : A string.
 Args     : None.

=cut

sub errstr
{
    $_[0]->db->db_handle->errstr || "";
}

=head2 db

 Title    : db
 Usage    : $db = $adaptor->db() or $adaptor->db($dbobj);
 Function : Get/set the database object this adaptor is using.
 Returns  : An OPOSSUM::DBSQL::DBConnection object.
 Args     : None or an OPOSSUM::DBSQL::DBConnection object.

=cut

sub db
{
    my ($self, $db) = @_;

    if ($db) {
	$self->{-db} = $db;
    }

    return $self->{-db};
}

1;
