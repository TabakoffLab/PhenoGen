=head1 NAME

OPOSSUM::DBSQL::TFInfoAdaptor - Adaptor for MySQL queries to retrieve
and store TFBS infomation.

=head1 SYNOPSIS

$tfia = $db_adaptor->get_TFInfoAdaptor();

=head1 DESCRIPTION

The tf_info table contains records which store information about the TFBS
position weight matrices.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::DBSQL::TFInfoAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::TFInfoSet;
use OPOSSUM::TFInfo;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_tf_ids

 Title    : fetch_tf_ids
 Usage    : $ids = $tfia->fetch_tf_ids($where_clause);
 Function : Fetch a list of all the TF IDs, optionally using
 	    a where clause.
 Returns  : A list ref of integer TF IDs.
 Args	  : Optionally an SQL where clause.

=cut

sub fetch_tf_ids
{
    my ($self, $where_clause) = @_;

    my $sql = qq{select tf_id from tf_info};
    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    $sql .= " order by tf_id";

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TF IDs\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TF IDs\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($ids) = $sth->fetchrow_array) {
	push @ids, $ids;
    }

    return @ids ? \@ids : undef;
}

=head2 fetch_external_ids

 Title    : fetch_external_ids
 Usage    : $ids = $tfia->fetch_external_ids($where_clause);
 Function : Fetch a list of all the TFBS external IDs, optionally using
 	    a where clause.
 Returns  : A list ref of TFBS external ID strings.
 Args	  : Optionally an SQL where clause.

=cut

sub fetch_external_ids
{
    my ($self, $where_clause) = @_;

    my $sql = qq{select external_id from tf_info};
    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    $sql .= " order by external_id";

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS external IDs\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS external IDs\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($ids) = $sth->fetchrow_array) {
	push @ids, $ids;
    }

    return @ids ? \@ids : undef;
}

=head2 fetch_names

 Title    : fetch_names
 Usage    : $names = $tfia->fetch_names($where_clause);
 Function : Fetch a list of all the TFBS profile names, optionally using
 	    a where clause.
 Returns  : A list ref of TFBS profile name strings.
 Args	  : Optionally an SQL where clause.

=cut

sub fetch_names
{
    my ($self, $where_clause) = @_;

    my $sql = qq{select name from tf_info};
    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    $sql .= " order by name";

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS names\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS names\n" . $self->errstr;
	return;
    }

    my @names;
    while (my ($name) = $sth->fetchrow_array) {
	push @names, $name;
    }

    return @names ? \@names : undef;
}

=head2 fetch_by_tf_id

 Title    : fetch_by_tf_id
 Usage    : $tfi = $tfia->fetch_by_tf_id($id);
 Function : Fetch a TFBS info object by it's TF ID.
 Returns  : An OPOSSUM::TFInfo object.
 Args	  : An integer TFBS pair ID.

=cut

sub fetch_by_tf_id
{
    my ($self, $id) = @_;

    my $sql = qq{
    		select external_db, external_id, name, class, phylum, width, ic
		from tf_info
		where tf_id = $id};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS info with tf_id $id\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS info with tf_id $id\n" . $self->errstr;
	return;
    }

    my $tf_info;
    if (my @row = $sth->fetchrow_array) {
	$tf_info = OPOSSUM::TFInfo->new(
					-id		=> $id,
					-external_db	=> $row[0],
					-external_id	=> $row[1],
					-name		=> $row[2],
					-class		=> $row[3],
					-phylum		=> $row[4],
					-width		=> $row[5],
					-ic		=> $row[6]);
    }
    $sth->finish;

    return $tf_info;
}

=head2 fetch_by_name

 Title    : fetch_by_name
 Usage    : $tfi = $tfia->fetch_by_name($name);
 Function : Fetch a TFBS info object by it's name.
 Returns  : An OPOSSUM::TFInfo object.
 Args	  : Optionally a TFBS name string.

=cut

sub fetch_by_name
{
    my ($self, $name) = @_;

    my $sql = qq{
    		select tf_id,
			external_db,
			external_id,
			class,
			phylum,
			width,
			ic
		from tf_info
		where name = '$name'};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS info with name $name\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS info with name $name\n" . $self->errstr;
	return;
    }

    my $tf_info;
    if (my @row = $sth->fetchrow_array) {
	$tf_info = OPOSSUM::TFInfo->new(
					-id		=> $row[0],
					-external_db	=> $row[1],
					-external_id	=> $row[2],
					-name		=> $name,
					-class		=> $row[3],
					-phylum		=> $row[4],
					-width		=> $row[5],
					-ic		=> $row[6]);
    }
    $sth->finish;

    return $tf_info;
}

=head2 fetch_by_external_id

 Title    : fetch_by_external_id
 Usage    : $tfi = $tfia->fetch_by_external_id($xid);
 Function : Fetch a TFBS info object by it's external ID.
 Returns  : An OPOSSUM::TFInfo object.
 Args	  : Optionally a TFBS external ID string.

=cut

sub fetch_by_external_id
{
    my ($self, $external_id) = @_;

    my $sql = qq{
    		select tf_id, external_db, name, class, phylum, width, ic
		from tf_info
		where external_id = '$external_id'};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS info with external_id $external_id\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS info with external_id $external_id\n"
		. $self->errstr;
	return;
    }

    my $tf_info;
    if (my @row = $sth->fetchrow_array) {
	$tf_info = OPOSSUM::TFInfo->new(
					-id		=> $row[0],
					-external_db	=> $row[1],
					-external_id	=> $external_id,
					-name		=> $row[2],
					-class		=> $row[3],
					-phylum		=> $row[4],
					-width		=> $row[5],
					-ic		=> $row[6]);
    }
    $sth->finish;

    return $tf_info;
}

=head2 fetch_tf_info_list

 Title    : fetch_tf_info_list
 Usage    : $tfi = $tfia->fetch_tf_info_list($where_clause, $sort_field);
 Function : Fetch a list of TFInfo objects.
 Returns  : A list ref of OPOSSUM::TFInfo objects.
 Args	  : An optional where clause,
 	    an optional sort field.

=cut

sub fetch_tf_info_list
{
    my ($self, $where_clause, $sort_field) = @_;

    my $sql = qq{
    		select tf_id,
			external_db,
			external_id,
			name,
			class,
			phylum,
			width,
			ic
		from tf_info};

    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    if ($sort_field) {
    	$sql .= " sort by $sort_field";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS info\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS info\n" . $self->errstr;
	return;
    }

    my @tf_info_list;
    while (my @row = $sth->fetchrow_array) {
	push @tf_info_list, OPOSSUM::TFInfo->new(
					-id		=> $row[0],
					-external_db	=> $row[1],
					-external_id	=> $row[2],
					-name		=> $row[3],
					-class		=> $row[4],
					-phylum		=> $row[5],
					-width		=> $row[6],
					-ic		=> $row[7]);
    }
    $sth->finish;

    return @tf_info_list ? \@tf_info_list : undef;
}

=head2 fetch_tf_info_set

 Title    : fetch_tf_info_set
 Usage    : $tfi = $tfia->fetch_tf_info_set($where_clause);
 Function : Fetch a set of TFInfo objects.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : An optional where clause.

=cut

sub fetch_tf_info_set
{
    my ($self, $where_clause) = @_;

    my $sql = qq{
    		select tf_id,
			external_db,
			external_id,
			name,
			class,
			phylum,
			width,
			ic
		from tf_info};

    if ($where_clause) {
    	$sql .= " where $where_clause";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS info\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS info\n" . $self->errstr;
	return;
    }

    my $tf_info_set = OPOSSUM::TFInfoSet->new();
    while (my @row = $sth->fetchrow_array) {
	$tf_info_set->add_tf_info(OPOSSUM::TFInfo->new(
					-id		=> $row[0],
					-external_db	=> $row[1],
					-external_id	=> $row[2],
					-name		=> $row[3],
					-class		=> $row[4],
					-phylum		=> $row[5],
					-width		=> $row[6],
					-ic		=> $row[7]));
    }
    $sth->finish;

    return $tf_info_set;
}

=head2 fetch_by_tf_ids

 Title    : fetch_by_tf_ids
 Usage    : $tfis = $tfia->fetch_by_tf_ids($ids);
 Function : Fetch a list of TFBS info objects by their TF IDs.
 Returns  : A list ref of OPOSSUM::TFInfo objects.
 Args	  : Optionally a list ref of integer TF IDs,
            optionally an external database name,
            optionally a field name to sort on

=cut

sub fetch_by_tf_ids
{
    my ($self, $ids, $xdb, $sort_field) = @_;

    my $where_clause;
    if ($ids) {
    	$where_clause = "tf_id in (";
	$where_clause .= join ',', @$ids;
	$where_clause .= ")";
    }

    if ($xdb) {
    	if ($ids) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_list($where_clause, $sort_field);
}

=head2 fetch_by_external_ids

 Title    : fetch_by_external_ids
 Usage    : $tfis = $tfia->fetch_by_external_ids($ids);
 Function : Fetch a list of TFBS info objects by their external IDs.
 Returns  : An list ref of OPOSSUM::TFInfo objects.
 Args	  : Optionally a list ref of external IDs,
            optionally an external database name,
            optionally a field name to sort on

=cut

sub fetch_by_external_ids
{
    my ($self, $xids, $xdb, $sort_field) = @_;

    my $where_clause;
    if ($xids) {
    	$where_clause = "external_id in (";
	$where_clause .= join ',', @$xids;
	$where_clause .= ")";
    }

    if ($xdb) {
    	if ($xids) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_list($where_clause, $sort_field);
}

=head2 fetch_by_names

 Title    : fetch_by_names
 Usage    : $tfis = $tfia->fetch_by_names($names);
 Function : Fetch a list of TFBS info objects by their names.
 Returns  : A list ref of OPOSSUM::TFInfo objects.
 Args	  : Optionally a list ref of TF names,
            optionally an external database name,
            optionally a field name to sort on

=cut

sub fetch_by_names
{
    my ($self, $names, $xdb, $sort_field) = @_;

    my $where_clause;
    if ($names) {
    	$where_clause = "name in (";
	$where_clause .= join ',', @$names;
	$where_clause .= ")";
    }

    if ($xdb) {
    	if ($names) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_list($where_clause, $sort_field);
}

=head2 fetch_by_min_ic

 Title    : fetch_by_min_ic
 Usage    : $tfis = $tfia->fetch_by_min_ic($min_ic);
 Function : Fetch a list of TFBS info objects with IC >= $min_ic.
 Returns  : A listref of OPOSSUM::TFInfo objects.
 Args	  : A minimum information content (IC),
            optionally an external database name,
            optionally a field name to sort on

=cut

sub fetch_by_min_ic
{
    my ($self, $min_ic, $xdb, $sort_field) = @_;

    my $where_clause;
    if ($min_ic) {
	$where_clause = "ic >= $min_ic";
    }

    if ($xdb) {
    	if ($min_ic) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_list($where_clause, $sort_field);
}

=head2 fetch_by_phylums

 Title    : fetch_by_phylums
 Usage    : $tfis = $tfia->fetch_by_phylums($phylums);
 Function : Fetch a list of TFBS info objects which are associated with the
 	    given phylums (taxonomic supergroups).
 Returns  : A listref of OPOSSUM::TFInfo objects.
 Args	  : Optionally a list ref of phylums (taxonomic supergroups),
            optionally an external database name,
            optionally a field name to sort on

=cut

sub fetch_by_phylums
{
    my ($self, $phylums, $xdb, $sort_field) = @_;

    my $where_clause;
    if ($phylums) {
    	$where_clause = "phylum in ('";
	$where_clause .= join "','", @$phylums;
	$where_clause .= "')";
    }

    if ($xdb) {
    	if ($phylums) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_set($where_clause, $sort_field);
}

=head2 fetch_by_external_db

 Title    : fetch_by_external_db
 Usage    : $tfis = $tfia->fetch_by_external_db($db);
 Function : Fetch a list of TFBS info objects with the given external
 	    DB name.
 Returns  : An listref of OPOSSUM::TFInfo objects.
 Args	  : An external DB name,
            optionally a field name to sort on

=cut

sub fetch_by_external_db
{
    my ($self, $db, $sort_field) = @_;

    my $where_clause;
    if ($db) {
	$where_clause = "external_db = '$db'";
    } else {
    	$where_clause = "external_db is NULL";
    }

    return $self->fetch_tf_info_list($where_clause, $sort_field);
}

=head2 fetch_tf_info_set_by_tf_ids

 Title    : fetch_tf_info_set_by_tf_ids
 Usage    : $tfis = $tfia->fetch_tf_info_set_by_tf_ids($ids);
 Function : Fetch a set of TFBS info objects by their TF IDs.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : Optionally a list ref of integer TF IDs,
	    optionally an external database name

=cut

sub fetch_tf_info_set_by_tf_ids
{
    my ($self, $ids, $xdb) = @_;

    my $where_clause;
    if ($ids) {
    	$where_clause = "tf_id in (";
	$where_clause .= join ',', @$ids;
	$where_clause .= ")";
    }

    if ($xdb) {
    	if ($ids) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_set($where_clause);
}

=head2 fetch_tf_info_set_by_external_ids

 Title    : fetch_tf_info_set_by_external_ids
 Usage    : $tfis = $tfia->fetch_tf_info_set_by_external_ids($ids);
 Function : Fetch a set of TFBS info objects by their external IDs.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : Optionally a list ref of external IDs,
	    optionally an external database name

=cut

sub fetch_tf_info_set_by_external_ids
{
    my ($self, $xids, $xdb) = @_;

    my $where_clause;
    if ($xids) {
    	$where_clause = "external_id in (";
	$where_clause .= join ',', @$xids;
	$where_clause .= ")";
    }

    if ($xdb) {
    	if ($xids) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_set($where_clause);
}

=head2 fetch_tf_info_set_by_names

 Title    : fetch_tf_info_set_by_names
 Usage    : $tfis = $tfia->fetch_tf_info_set_by_names($names);
 Function : Fetch a set of TFBS info objects by their names.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : Optionally a list ref of TFBS names,
	    optionally an external database name

=cut

sub fetch_tf_info_set_by_names
{
    my ($self, $names, $xdb) = @_;

    my $where_clause;
    if ($names) {
    	$where_clause = "name in (";
	$where_clause .= join ',', @$names;
	$where_clause .= ")";
    }

    if ($xdb) {
    	if ($names) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_set($where_clause);
}

=head2 fetch_tf_info_set_by_min_ic

 Title    : fetch_tf_info_set_by_min_ic
 Usage    : $tfis = $tfia->fetch_tf_info_set_by_min_ic($min_ic);
 Function : Fetch a set of TFBS info objects with IC >= $min_ic.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : A minimum information content (IC),
	    optionally an external database name

=cut

sub fetch_tf_info_set_by_min_ic
{
    my ($self, $min_ic, $xdb) = @_;

    my $where_clause;
    if ($min_ic) {
	$where_clause = "ic >= $min_ic";
    }

    if ($xdb) {
    	if ($min_ic) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_set($where_clause);
}

=head2 fetch_tf_info_set_by_phylums

 Title    : fetch_tf_info_set_by_phylums
 Usage    : $tfis = $tfia->fetch_tf_info_set_by_phylums($phylums);
 Function : Fetch a set of TFBS info objects which are associated with the
 	    given phylums (taxonomic supergroups).
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : Optionally a list ref of phylums (taxonomic supergroups),
	    optionally an external database name

=cut

sub fetch_tf_info_set_by_phylums
{
    my ($self, $phylums, $xdb) = @_;

    my $where_clause;
    if ($phylums) {
    	$where_clause = "phylum in ('";
	$where_clause .= join "','", @$phylums;
	$where_clause .= "')";
    }

    if ($xdb) {
    	if ($phylums) {
	    $where_clause .= " and ";
	}
    	$where_clause .= "external_db = '$xdb'";
    }

    return $self->fetch_tf_info_set($where_clause);
}

=head2 fetch_tf_info_set_by_external_db

 Title    : fetch_tf_info_set_by_external_db
 Usage    : $tfis = $tfia->fetch_tf_info_set_by_external_db($db);
 Function : Fetch a set of TFBS info objects with the given external
 	    DB name.
 Returns  : An OPOSSUM::TFInfoSet object.
 Args	  : An external DB name.

=cut

sub fetch_tf_info_set_by_external_db
{
    my ($self, $xdb) = @_;

    my $where_clause;
    if ($xdb) {
	$where_clause = "external_db = '$xdb'";
    } else {
    	$where_clause = "external_db is NULL";
    }

    return $self->fetch_tf_info_set($where_clause);
}

=head2 store

 Title   : store
 Usage   : $id = $tfia->store($tf_info);
 Function: Store tf_info record in the database.
 Args    : The OPOSSUM::TFInfo object to store.
 Returns : A database ID of the newly stored tf_info record.

=cut

sub store
{
    my ($self, $tf_info) = @_;

    if (!ref $tf_info || !$tf_info->isa('OPOSSUM::TFInfo')) {
    	carp "Not an OPOSSUM::TFInfo object";
	return;
    }

    my $sql = qq{insert into tf_info
		    (external_db, external_id, name, class, phylum, width, ic)
		    values (?, ?, ?, ?, ?, ?, ?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert tf_info statement\n" . $self->errstr;
	return;
    }

    if (!$sth->execute($tf_info->external_db,
    			$tf_info->external_id,
    			$tf_info->name,
    			$tf_info->class,
    			$tf_info->phylum,
    			$tf_info->width,
			$tf_info->ic))
    {
    	carp "Error inserting tf_info record\n" . $self->errstr;
	return;
    }
    $sth->finish;

    return $sth->{'mysql_insertid'};
}

1;
