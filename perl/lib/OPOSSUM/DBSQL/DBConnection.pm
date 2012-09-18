=head1 NAME

OPOSSUM::DBSQL::DBConnection - object to encapsulate and manage a databse
connection (wraps a DBI connection).

=head1 SYNOPSIS

 $db = OPOSSUM::DBSQL::DBConnection->new(
			    -user   => 'opossum_r',
			    -dbname => 'oPOSSUM',
			    -host   => 'localhost');


=head1 DESCRIPTION

This is a wrapper for a DBI connection.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=cut
package OPOSSUM::DBSQL::DBConnection;

# Required for now for the require in _get_adaptor. Can be removed once
# OPOSSUM lib is installed in standard perl lib dirs.
#use lib '/space1/home/dave/devel/OPOSSUM/lib';

use strict;

use DBI;
use Carp;

#
# Defaults
#
use constant HOST	=> 'localhost';
use constant PORT	=> 3306;
use constant DBNAME	=> 'oPOSSUM';
use constant USER	=> 'opossum_r';
use constant DRIVER	=> 'mysql';

=head2 new

 Title    : new
 Usage    : $db = OPOSSUM::DBSQL::DBConnection->new(
				    -user	=> 'possum',
				    -host	=> 'localhost',
				    -dbname	=> 'OPOSSUM');
 Function : Connect to a database and return connection as a
 	    OPOSSUM::DBSQL::DBConnection object.
 Returns  : A new OPOSSUM::DBSQL::DBConnection object
 Args	  : user     - the database user name to connect with,
	    password - password for this user to connect,
 	    host     - name of database host machine (default = 'localhost'),
	    port     - port number to user when connecting to database
	    	       (default = 3306),
	    driver   - type of database driver (default = 'mysql'),
	    dbname   - the name of the database to connect to.

=cut

sub new
{
    my ($class, %args) = @_;

    my $host	= $args{-host}		|| HOST;
    my $port	= $args{-port}		|| PORT;
    my $driver	= $args{-driver}	|| DRIVER;
    my $dbname	= $args{-dbname}	|| DBNAME;
    my $user	= $args{-user}		|| USER;
    my $pass	= $args{-password};

    my $dsn = "DBI:$driver:database=$dbname;host=$host;port=$port";

    my $dbh;
    eval {
	$dbh = DBI->connect("$dsn", "$user", $pass);
    };

    if (!$dbh) {
	carp "Could not connect to database $dbname user $user using [$dsn]"
		. " as a locator\n";
	return;
    }

    my $self = bless {
		    -host	=> $host,
		    -port	=> $port,
		    -driver	=> $driver,
		    -user	=> $user,
		    -password	=> $pass,
		    -dbname	=> $dbname,
		    _db_handle	=> $dbh
		}, ref $class || $class;

    return $self;
}

=head2 DESTROY

 Title    : DESTROY
 Usage    : none.
 Function : Disconnects any active database connections. Automatically
 	    called by the garbage collector. Should never be explicitly
	    called.
 Returns  : Nothing.
 Args	  : None.

=cut

sub DESTROY
{
    my $self = shift;

    $self->disconnect;
}

=head2 disconnect

 Title    : disconnect
 Usage    : $db->disconnect();
 Function : Disconnect from the database.
 Returns  : Nothing.
 Args	  : None.

=cut

sub disconnect
{
    my $self = shift;

    if ($self->{_db_handle}) {
	$self->{_db_handle}->disconnect;
	$self->{_db_handle} = undef;
    }
}

=head2 host

 Title    : host
 Usage    : $host = $db->host();
 Function : Return the name of the database host machine.
 Returns  : A host name string.
 Args	  : None.

=cut

sub host
{
    $_[0]->{host};
}

=head2 user

 Title    : user
 Usage    : $user = $db->user();
 Function : Return the name of the user connected to the database.
 Returns  : A user name string.
 Args	  : None.

=cut

sub user
{
    $_[0]->{user};
}

=head2 dbname

 Title    : dbname
 Usage    : $dbname = $db->dbname();
 Function : Return the name of the database.
 Returns  : A database name string.
 Args	  : None.

=cut

sub dbname
{
    $_[0]->{dbname};
}

=head2 port

 Title    : port
 Usage    : $port = $db->port();
 Function : Return the port number of the database connection.
 Returns  : A database port number.
 Args	  : None.

=cut

sub port
{
    $_[0]->{port};
}

=head2 driver

 Title    : driver
 Usage    : $driver = $db->driver();
 Function : Return the database driver name.
 Returns  : A database driver name string.
 Args	  : None.

=cut

sub driver
{
    $_[0]->{driver};
}

=head2 password

 Title    : password
 Usage    : $password = $db->password();
 Function : Return the password used to connect to the database.
 Returns  : A password string.
 Args	  : None.

=cut

sub password
{
    $_[0]->{password};
}

=head2 _get_adaptor

 Title    : _get_adaptor
 Usage    : $adpator = $self->_get_adaptor("full::adaptor::name");
 Function : Used by subclasses to obtain adaptor objects for this
 	    database connection using the fully qualified module name
	    of the adaptor. If the adaptor has not been retrieved before
	    it is created, otherwise it is retrieved from the adaptor
	    cache.
 Returns  : Adaptor object.
 Args	  : Fully qualified adaptor module name,
 	    optional arguments to be passed to the adaptor constructor.

=cut

sub _get_adaptor
{
    my ($self, $module, $ext) = @_;

    my ($adaptor, $internal_name);
  
    #Create a private member variable name for the adaptor by replacing
    #:: with _
  
    $internal_name = $module;

    $internal_name =~ s/::/_/g;

    if ($ext) {
    	$internal_name .= "_$ext";
    }

    unless (defined $self->{'_adaptors'}{$internal_name}) {
	eval "require $module";
    
	if($@) {
	    carp "$module cannot be found.\nException $@\n";
	    return undef;
	}
      
	$adaptor = "$module"->new($self, $ext);

	$self->{'_adaptors'}{$internal_name} = $adaptor;
    }

    return $self->{'_adaptors'}{$internal_name};
}

=head2 db_handle

 Title    : db_handle
 Usage    : $dbh = $db->db_handle() or db->db_handle($dbh);
 Function : Get/set the database handle used by this database connection.
 Returns  : DBI database handle.
 Args	  : None of a new DBI database handle.

=cut

sub db_handle
{
    my ($self, $value) = @_;

    if (defined $value) {
	$self->{'_db_handle'} = $value;
    }
    return $self->{'_db_handle'};
}

=head2 prepare

 Title    : prepare
 Usage    : $sth = $db->prepare($sql);
 Function : Prepare an SQL statement using the internal DBI database
 	    handle and return the DBI statement handle.
 Returns  : DBI statement handle.
 Args	  : SQL statment to prepare.

=cut

sub prepare
{
    my ($self, $string) = @_;

    if (!$string) {
	carp "Attempting to prepare an empty SQL query.";
	return;
    }

    if(!defined $self->{_db_handle}) {
	carp "Database object has lost its database handle.";
	return;
    }

    return $self->{_db_handle}->prepare($string);
}

=head2 do

 Title    : do
 Usage    : $result = $db->do($sql);
 Function : Execute an SQL statement using the internal DBI handle.
 Returns  : Result if dbh DBI do() statement.
 Args	  : SQL statment to execute.

=cut

sub do
{
    my ($self, $sql, $attr, @bind_values) = @_;

    if (!$sql) {
	carp "Attempting to run an empty SQL query.";
	return;
    }

    if(!defined $self->{_db_handle}) {
	carp "Database object has lost its database handle.";
	return;
    }

    return $self->{_db_handle}->do($sql, $attr, @bind_values);
}

=head2 rollback

 Title    : rollback
 Usage    : $result = $db->rollback();
 Function : Execute a rollback statement using the internal DBI handle.
 	    NOTE: this is only supported on databases which support
	    transaction processing. i.e. InnoDB.
 Returns  : Result if dbh DBI rollback() statement.
 Args	  : None.

=cut

sub rollback
{
    my ($self) = @_;

    if(!defined $self->{_db_handle}) {
	carp "Database object has lost its database handle.";
	return;
    }

    return $self->{_db_handle}->rollback();
}

=head2 commit

 Title    : commit
 Usage    : $result = $db->commit();
 Function : Execute a commit statement using the internal DBI handle.
 	    NOTE: this is only supported on databases which support
	    transaction processing. i.e. InnoDB.
 Returns  : Result if dbh DBI commit() statement.
 Args	  : None.

=cut

sub commit
{
    my ($self) = @_;

    if(!defined $self->{_db_handle}) {
	carp "Database object has lost its database handle.";
	return;
    }

    return $self->{_db_handle}->commit();
}

=head2 errstr

 Title    : errstr
 Usage    : $err = $db->errstr();
 Function : Return the last DBI error string.
 Returns  : DBI error string.
 Args	  : None.

=cut

sub errstr
{
    $_[0]->db_handle->errstr || "";
}

sub add_db_adaptor
{
    my ($self, $name, $adaptor) = @_;

    unless ($name && $adaptor && ref $adaptor) {
	carp 'adaptor and name arguments are required';
	return;
    } 
				   
    #avoid circular references and memory leaks
    #if($adaptor->isa('Bio::EnsEMBL::Container')) {
    #	$adaptor = $adaptor->_obj;
    #}

    $self->{'_db_adaptors'}->{$name} = $adaptor;
}

sub remove_db_adaptor
{
    my ($self, $name) = @_;

    my $adaptor = $self->{'_db_adaptors'}->{$name};
    delete $self->{'_db_adaptors'}->{$name};

    unless($adaptor) {
	return undef;
    }

    return $adaptor;
}

sub get_all_db_adaptors
{
    my ($self) = @_;   

    unless(defined $self->{'_db_adaptors'}) {
	return {};
    }

    return $self->{'_db_adaptors'};
}

sub get_db_adaptor {
    my ($self, $name) = @_;

    unless($self->{'_db_adaptors'}->{$name}) {
	return undef;
    }

    return $self->{'_db_adaptors'}->{$name};
}

sub deleteObj
{
    my $self = shift;

    foreach my $adaptor_name (keys %{$self->{'_adaptors'}}) {
	my $adaptor = $self->{'_adaptors'}->{$adaptor_name};

	#call each of the adaptor deleteObj methods
	if ($adaptor && $adaptor->can('deleteObj')) {
	    $adaptor->deleteObj();
	}

	#break dbadaptor -> object adaptor references
	$self->{'_adaptors'}->{$adaptor_name} = undef;
    }

    #break dbadaptor -> dbadaptor references
    foreach my $db_name (keys %{$self->get_all_db_adaptors()}) {
	$self->remove_db_adaptor($db_name);
    }
}

1;
