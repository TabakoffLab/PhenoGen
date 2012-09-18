=head1 NAME

OPOSSUM::DBSQL::TFBSCountsAdaptor - Adaptor for MySQL queries to retrieve
and store TFBS counts.

=head1 SYNOPSIS

$tfbsca = $db_adaptor->get_TFBSCountsAdaptor();

=head1 DESCRIPTION

In order to facilitate fast retrieval of TFBS counts from the oPOSSUM database
several count sets were pre-computed using discrete values for PWM (PSSM)
thresholds, conservation levels, and upstream/downstream search regions.
This adaptor provides an interface to these pre-computed counts stored in
the tfbs_counts table.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut
package OPOSSUM::DBSQL::TFBSCountAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::TFBSCount;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

sub new
{
    my ($class, $dbobj, $ext) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new($dbobj);

    $self->{-extended_table_name} = $ext;

    return $self;
}

=head2 fetch_tf_ids

 Title    : fetch_tf_ids
 Usage    : $ids = $tfbsca->fetch_tf_ids();
 Function : Fetch all the TF IDs in the tfbs_counts table
 Returns  : A ref to a list of TF IDs
 Args	  : None

=cut

sub fetch_tf_ids
{
    my ($self) = @_;

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
			    if $self->{-extended_table_name};
    my $sql = qq{select distinct tf_id from $table};

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
    while (my ($id) = $sth->fetchrow_array) {
	push @ids, $id;
    }

    return @ids ? \@ids : undef;
}

=head2 fetch_gene_pair_ids

 Title    : fetch_gene_pair_ids
 Usage    : $ids = $tfbsca->fetch_gene_pair_ids();
 Function : Fetch all the gene pair IDs in the tfbs_counts table
 Returns  : A ref to a list of gene pair IDs
 Args	  : None

=cut

sub fetch_gene_pair_ids
{
    my ($self) = @_;

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
			    if $self->{-extended_table_name};
    my $sql = qq{select distinct gene_pair_id from $table};

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching gene pair IDs\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching gene pair IDs\n" . $self->errstr;
	return;
    }

    my @ids;
    while (my ($id) = $sth->fetchrow_array) {
	push @ids, $id;
    }

    return @ids ? \@ids : undef;
}

=head2 fetch_gene_pair_tfbs_count

 Title    : fetch_gene_pair_tfbs_count
 Usage    : $count = $tfbsca->fetch_gene_pair_tfbs_count(
 				-conservation_level	=> $clevel,
				-threshold_level	=> $thlevel,
				-search_region_level	=> $srlevel,
				-gene_pair_id		=> $gpid,
				-tf_id			=> $tfid);
 Function : Fetch a gene pair TFBS count
 Returns  : An OPOSSUM::TFBSCount object
 Args	  : gene_pair_id	- gene pair ID
	    tf_id		- TF ID
	    conservation_level	- conservation level
	    threshold_level	- threshold level
	    search_region_level	- search region level

=cut

sub fetch_gene_pair_tfbs_count
{
    my ($self, %args) = @_;

    my $gpid = $args{-gene_pair_ids};
    my $tfid = $args{-tf_ids};
    my $cons_level = $args{-conservation_level};
    my $thresh_level = $args{-threshold_level};
    my $sr_level = $args{-search_region_level};

    if (!$gpid || !$tfid || !$cons_level || !$thresh_level || !$sr_level) {
    	carp "must provide gene_pair_id, tf_id, conservation_level,"
		. " threshold_level and search_region_level\n";
	return;
    }

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
			    if $self->{-extended_table_name};
    my $sql = qq{
		select gene_pair_id, tf_id, conservation_level,
			threshold_level, search_region_level, count
		from $table
		where gene_pair_id = $gpid
		and tf_id = $tfid
		and conservation_level = $cons_level
		and threshold_level = $thresh_level
		and search_region_level = $sr_level
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS count with\n$sql\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS count with\n$sql\n"
		. $self->errstr;
	return;
    }

    my $count;
    if (my @row = $sth->fetchrow_array) {
	$count = OPOSSUM::TFBSCount->new(
				-gene_pair_id		=> $row[0],
				-tf_id			=> $row[1],
				-conservation_level	=> $row[2],
				-threshold_level	=> $row[3],
				-search_region_level	=> $row[4],
				-count			=> $row[5]);
    }
    $sth->finish;

    return $count;
}

=head2 fetch_gene_pair_tfbs_counts

 Title    : fetch_gene_pair_tfbs_counts
 Usage    : $counts = $tfbsca->fetch_gene_pair_tfbs_counts(
 				-conservation_level	=> $clevel,
				-threshold_level	=> $thlevel,
				-search_region_level	=> $srlevel,
				-gene_pair_ids		=> $gpids,
				-tf_ids			=> $tfids);
 Function : Fetch a list of gene pair TFBS counts
 Returns  : A ref to a list of OPOSSUM::TFBSCount objects
 Args	  : conservation_level	- optionally retrieve only gene pair
 				  TFBS counts with this conservation
				  level
	    threshold_level	- optionally retrieve only gene pair
	    			  TFBS counts with this threshold level
	    search_region_level	- optionally retrieve only gene pair
				  TFBS counts whith this search region
				  level
	    gene_pair_ids	- optionally restrict the gene pair
	    			  TFBS counts to only those gene pairs
				  identified by these gene pair IDs
	    tf_ids		- optionally restrict the gene pair
	    			  TFBS counts to only those TFBS profiles
				  identified by these TF IDs

=cut

sub fetch_gene_pair_tfbs_counts
{
    my ($self, %args) = @_;

    my $gpids = $args{-gene_pair_ids};
    my $tfids = $args{-tf_ids};
    my $cons_level = $args{-conservation_level};
    my $thresh_level = $args{-threshold_level};
    my $sr_level = $args{-search_region_level};

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
			    if $self->{-extended_table_name};
    my $sql = qq{
		select gene_pair_id, tf_id, conservation_level,
			threshold_level, search_region_level, count
		from $table
	    };

    my $where = "where";
    if (defined $cons_level) {
    	$sql .= " $where conservation_level = $cons_level";
	$where = "and";
    }

    if (defined $thresh_level) {
    	$sql .= " $where threshold_level = $thresh_level";
	$where = "and";
    }

    if (defined $sr_level) {
    	$sql .= " $where search_region_level = $sr_level";
	$where = "and";
    }

    if ($gpids && $gpids->[0]) {
        $sql .= " $where gene_pair_id in (";
	$sql .= join(',', @$gpids);
        $sql .= ")";
	$where = "and";
    }

    if ($tfids && $tfids->[0]) {
        $sql .= " $where tf_id in (";
	$sql .= join(',', @$tfids);
        $sql .= ")";
    }

    $sql .= " order by gene_pair_id, tf_id";

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS counts with\n$sql\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS counts with\n$sql\n" . $self->errstr;
	return;
    }

    #
    # Maybe we should return some sort of TFBSCountSet?
    #
    my @counts;
    while (my @row = $sth->fetchrow_array) {
	push @counts, OPOSSUM::TFBSCount->new(
				-gene_pair_id		=> $row[0],
				-tf_id			=> $row[1],
				-conservation_level	=> $row[2],
				-threshold_level	=> $row[3],
				-search_region_level	=> $row[4],
				-count			=> $row[5]);
    }
    $sth->finish;

    return @counts ? \@counts : undef;
}

=head2 store

 Title   : store
 Usage   : $tfbsca->store($count);
 Function: Store TFBS count in the database.
 Args    : An OPOSSUM::TFBSCount object
 Returns : True on success, false otherwise.

=cut

sub store
{
    my ($self, $tfbsc) = @_;

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
			    if $self->{-extended_table_name};
    my $sql = qq{insert into $table
		    (gene_pair_id, tf_id, conservation_level,
		     threshold_level, search_region_level, count)
		    values (?, ?, ?, ?, ?, ?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert $table statement\n" . $self->errstr;
	return;
    }

    if (!$sth->execute($tfbsc->gene_pair_id, $tfbsc->tf_id,
    			$tfbsc->conservation_level,
    			$tfbsc->threshold_level, $tfbsc->search_region_level,
			$tfbsc->count))
    {
	carp sprintf("Error inserting TFBS count for GenePair ID %d TF ID %d"
		. $self->errstr, $tfbsc->gene_pair_id, $tfbsc->tf_id);
	return 0;
    }

    return 1;
}

=head2 store_list

 Title   : store_list
 Usage   : $tfbsca->store_list($counts);
 Function: Store TFBS counts in the database.
 Args    : A listref of OPOSSUM::TFBSCount objects
 Returns : True on success, false otherwise.

=cut

sub store_list
{
    my ($self, $tfbs_counts) = @_;

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
			    if $self->{-extended_table_name};
    my $sql = qq{insert into $table
		    (gene_pair_id, tf_id, conservation_level,
		     threshold_level, search_region_level, count)
		    values (?, ?, ?, ?, ?, ?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert $table statement\n" . $self->errstr;
	return;
    }

    my $ok = 1;
    foreach my $tfbsc (@$tfbs_counts) {
	if (!$sth->execute($tfbsc->gene_pair_id, $tfbsc->tf_id,
			    $tfbsc->conservation_level,
			    $tfbsc->threshold_level,
			    $tfbsc->search_region_level,
			    $tfbsc->count))
	{
	    carp sprintf("Error inserting TFBS count for GenePair ID %d"
	    		. " TF ID %d" . $self->errstr,
			$tfbsc->gene_pair_id, $tfbsc->tf_id);
	    $ok = 0;
	}
    }

    return $ok;
}

1;
