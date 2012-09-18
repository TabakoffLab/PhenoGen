=head1 NAME

OPOSSUM::DBSQL::Analysis::CountsAdaptor - Adaptor for MySQL queries to retrieve
and store gene pair TFBS counts.

=head1 SYNOPSIS

$aca = $db_adaptor->get_AnalysisCountsAdaptor();

=head1 DESCRIPTION

In order to facilitate fast retrieval of TFBS counts from the oPOSSUM database
several count sets were pre-computed using discrete values for PWM (PSSM)
thresholds, conservation levels, and upstream/downstream search regions.
This adaptor provides an interface to both the pre-computed counts as well as
the raw data used to compute counts and retrieves the information into a
OPOSSUM::Analysis::Counts object which can be passed directly to the
OPOSSUM::Analysis::Fisher and OPOSSUM::Analysis::Zscore modules.

=head1 CHANGE HISTORY

 DJA 2007/01/29
 - modified fetch_custom_counts method to call
   the new ConservedRegionAdaptor->fetch_length_by_upstream_downstream
   method to get the length directly instead of getting all the conserved
   region records with fetch_set_by_upstream_downstream and then calling
   the length method on them (more efficient???)

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

 Modified by Shannan Ho Sui on Dec 21, 2006 to accommodate schema changes

=head1 METHODS

=cut

package OPOSSUM::DBSQL::Analysis::CountsAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::Analysis::Counts;
use OPOSSUM::ConservedRegionLength;
use OPOSSUM::ConservedRegionLengthSet;

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

=head2 fetch_counts

 Title    : fetch_counts
 Usage    : $counts = $aca->fetch_counts(
 				-conservation_level	=> $clevel,
				-threshold_level	=> $thlevel,
				-search_region_level	=> $srlevel,
				-gene_pair_ids	        => $gpids,
				-tf_ids		=> $tfids);
 Function : Fetch the pre-computed counts of TFBS hits on the gene
	    pair sequences from the DB and build a
	    OPOSSUM::Analysis::Counts object.
 Returns  : An OPOSSUM::Analysis::Counts object.
 Args	  : conservation_level	- counts are retrieved for TFBSs which
 				  were found in conserved regions with
				  at least the conservation identified
				  by this conservation level
	    threshold_level	- counts are retrieved for TFBS hits
	    			  which had at least the threshold score
				  identified by this threshold level
	    search_region_level	- counts are retrieved for TFBSs which
	    			  fell within the search region identified
				  by this search region level
	    gene_pair_ids	- optionally restrict the counts to only
	    			  those gene pairs identified by
				  these gene pair IDs
	    tf_ids		- optionally restrict the counts to only
	    			  those TF profiles identified by these
				  TF IDs

=cut

sub fetch_counts
{
    my ($self, %args) = @_;

    my $cons_level = $args{-conservation_level};
    my $thresh_level = $args{-threshold_level};
    my $sr_level = $args{-search_region_level};
    my $gpids = $args{-gene_pair_ids};
    my $tfids = $args{-tf_ids};

    if (!$cons_level || !$thresh_level || !$sr_level) {
    	carp "must provide conservation_level, threshold_level and"
		. " search_region_level\n";
	return;
    }

    my $crla = $self->db->get_ConservedRegionLengthAdaptor;
    if (!$crla) {
	carp "error getting ConservedRegionLengthAdaptor\n";
	return;
    }

    my $table = "tfbs_counts";
    $table .= "_" . $self->{-extended_table_name}
    if $self->{-extended_table_name};

    my $sql = qq{
		select gene_pair_id, tf_id, count
		from $table
		where conservation_level = $cons_level
		and threshold_level = $thresh_level
		and search_region_level = $sr_level
	    };

    #print STDERR $sql ."\n";

    if ($gpids && $gpids->[0]) {
	$sql .= " and gene_pair_id in (";
	$sql .= join ',', @$gpids;
	$sql .= ")";
    }

    if ($tfids && $tfids->[0]) {
	$sql .= " and tf_id in (";
	$sql .= join ',', @$tfids;
	$sql .= ")";
    }

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching TFBS counts with\n$sql\n" . $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching TFBS counts with\n$sql\n" . $sth->errstr;
	return;
    }

    my $counts = OPOSSUM::Analysis::Counts->new();
    while (my @row = $sth->fetchrow_array) {
	$counts->gene_tfbs_count($row[0], $row[1], $row[2]);
    }
    $sth->finish;

    if ($gpids) {
    	$counts->gene_pair_ids($gpids);
    }
    if ($tfids) {
    	$counts->tf_ids($tfids);
    }

    my $crl_set = $crla->fetch_length_set(
    			    -gene_pair_ids		=> $gpids,
			    -conservation_level		=> $cons_level,
			    -search_region_level	=> $sr_level);

    $counts->conserved_region_length_set($crl_set);

    $counts->param('conservation_level', $cons_level);
    $counts->param('threshold_level', $thresh_level);
    $counts->param('search_region_level', $sr_level);

    return $counts
}

=head2 fetch_custom_counts

 Title    : fetch_custom_counts
 Usage    : $counts = $aca->fetch_custom_counts(
 				-conservation_level	=> $clevel,
				-threshold		=> $thresh,
				-upstream_bp		=> $upbp,
				-downstream_bp		=> $downbp,
				-gene_pair_ids  	=> $gpids,
				-tf_ids		        => $tfids);
 Function : Compute the counts of TFBS hits on the gene pair sequences
 	    from the DB and build an OPOSSUM::Analysis::Counts object.
 Returns  : An OPOSSUM::Analysis::Counts object.
 Args	  : conservation_level	- counts are retrieved for TFBSs which
 				  were found in conserved regions with
				  at least the conservation identified
				  by this conservation level
	    threshold		- counts are retrieved for TFBS hits
	    			  which had at least this threshold score
	    upstream_bp		- counts are retrieved for TFBSs which
	    			  fell within this number of bp upstream
				  of the TSS
	    downstream_bp	- counts are retrieved for TFBSs which
	    			  fell within this number of bp downstream
				  of the TSS
	    gene_pair_ids	- optionally restrict the counts to only
	    			  those gene pairs identified by
				  these gene pair IDs
	    tf_ids		- optionally restrict the counts to only
	    			  those TF profiles identified by these
				  TF IDs

=cut

sub fetch_custom_counts
{
    my ($self, %args) = @_;

    my $cons_level = $args{-conservation_level};
    my $threshold = $args{-threshold};
    my $upstream_bp = $args{-upstream_bp};
    my $downstream_bp = $args{-downstream_bp};
    my $gpids = $args{-gene_pair_ids};
    my $tfids = $args{-tf_ids};

    if (!$cons_level || !defined $threshold || !defined $upstream_bp
	    || !defined $downstream_bp)
    {
    	carp "must provide conservation_level, threshold, upstream_bp"
		. " and downstream_bp\n";
	return;
    }

    my $gpa = $self->db->get_GenePairAdaptor;
    if (!$gpa) {
    	carp "error getting GenePairAdaptor\n";
	return;
    }

    my $cra = $self->db->get_ConservedRegionAdaptor;
    if (!$cra) {
    	carp "error getting ConservedRegionAdaptor\n";
	return;
    }

    my $ext = $self->{-extended_table_name};
  
    my $ctfsa = $self->db->get_ConservedTFBSAdaptor($ext);
    if (!$ctfsa) {
    	carp "error getting ConservedTFBSAdaptor\n";
	return;
    }

    $gpids = $gpa->fetch_gene_pair_ids if !$gpids;

    my $counts = OPOSSUM::Analysis::Counts->new();
    my $crl_set = OPOSSUM::ConservedRegionLengthSet->new();
    my $count = 0;
    foreach my $gpid (@$gpids) {
	#print STDERR "$count\tGene: $gpid\n";
	#
	# DJA 2007/01/29
	# Call the new fetch_length_by_upstream_downstream method from
	# ConservedRegionAdaptor to get the length directly instead of
	# getting all the conserved region records with then calling
	# the length method on them (more efficient???)
	#
	#my $cr_set = $cra->fetch_set_by_upstream_downstream(
	#		    $gpid, $cons_level, $upstream_bp, $downstream_bp);
	my $length = $cra->fetch_length_by_upstream_downstream(
			    $gpid, $cons_level, $upstream_bp, $downstream_bp);
	#if (defined($cr_set)) {
	if ($length) {
	    my $crl = OPOSSUM::ConservedRegionLength->new(
			    -gene_pair_id	=> $gpid,
			    -conservation_level	=> $cons_level,
			    -length		=> $length);
	    $crl_set->add_conserved_region_length($crl);

	    my $gp_counts = $ctfsa->fetch_tfbs_counts(
				-gene_pair_id		=> $gpid,
				-conservation_level	=> $cons_level,
				-threshold		=> $threshold,
				-upstream_bp		=> $upstream_bp,
				-downstream_bp		=> $downstream_bp,
				-tf_ids			=> $tfids);

	    foreach my $gp_count (@$gp_counts) {
		$counts->gene_tfbs_count($gp_count->gene_pair_id,
					 $gp_count->tf_id, $gp_count->count);
	    }
	}
	$count++;
    }

    $counts->conserved_region_length_set($crl_set);

    $counts->gene_pair_ids($gpids);

    if ($tfids) {
    	$counts->tf_ids($tfids);
    }

    $counts->param('conservation_level', $cons_level);
    $counts->param('threshold', $threshold);
    $counts->param('upstream_bp', $upstream_bp);
    $counts->param('downstream_bp', $downstream_bp);

    return $counts
}

1;
