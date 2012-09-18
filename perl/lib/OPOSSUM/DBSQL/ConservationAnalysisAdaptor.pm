=head1 NAME

OPOSSUM::DBSQL::ConservationAnalysisAdaptor - Adaptor for MySQL queries to
retrieve information from the database as a ConservationAnalysis object.

=head1 SYNOPSIS

$caa = $db_adaptor->get_ConservationAnalysisAdaptor();

=head1 DESCRIPTION

Read necessary information from the alignments, exons and conserved_regions
tables of the oPOSSUM DB to build a ConservationAnalysis object.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::ConservationAnalysisAdaptor;

use strict;

use Carp;

use Bio::LocatableSeq;
use Bio::SimpleAlign;
use OPOSSUM::DBSQL::BaseAdaptor;
use ConservationAnalysis::ConservationAnalysis;
use Bio::SeqFeature::Gene::Exon;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

=head2 fetch_by_gene_pair_id

 Title    : fetch_by_gene_pair_id
 Usage    : $ca = $cca->fetch_by_gene_pair_id($id, $level);
 Function : Fetch a ConservationAnalysis object by it's associated
	    GenePair ID. If a conservation level is given, the conserved
	    regions stored at this level are retrieved and attached to
	    the object. Otherwise the conserved regions must be re-computed
	    by calling compute_conserved_regions. NOTE: the conserved regions
	    report object is not reconstructed as not all of the necessary
	    parameters are stored in the database.
 Returns  : A ConservationAnalysis::ConservationAnalysis object.
 Args	  : A GenePair ID,
 	    Optionally a conservation level.

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $gpid, $level) = @_;

    #
    # Fetch actual GenePair object
    #
    my $gpa = $self->db->get_GenePairAdaptor;
    if (!$gpa) {
    	carp "ERROR getting GenePairAdaptor\n";
	return;
    }

    my $gene_pair = $gpa->fetch_by_gene_pair_id($gpid);
    if (!$gene_pair) {
    	carp "Could not fetch GenePair $gpid\n";
	return;
    }

    #
    # Fetch associated sequences/alignment
    #
    my $aa = $self->db->get_AlignmentAdaptor;
    if (!$aa) {
    	carp "ERROR getting AlignmentAdaptor\n";
	return;
    }

    my $op_aln = $aa->fetch_by_gene_pair_id($gpid);
    if (!$op_aln) {
    	carp "Could not fetch alignment for GenePair $gpid\n";
	return;
    }

    #
    # Fetch associated species 1 exons
    #
    my $exa = $self->db->get_ExonAdaptor;
    if (!$exa) {
    	carp "ERROR getting ExonAdaptor\n";
	return;
    }

    my $op_exons = $exa->fetch_by_gene_pair_id($gpid, 1);
    if (!$op_exons) {
	carp "Could not fetch species 1 exons for GenePair $gpid\n";
	return;
    }

    my ($seq1, $seq2, $mseq1, $mseq2, $align) = _create_bio_seqs(
    							$gene_pair, $op_aln);

    my $bio_exons = _opossum_to_bio_exons($op_exons);

    my $ca = ConservationAnalysis::ConservationAnalysis->new(
                        base_seq                => $seq1,
                        comparison_seq          => $seq2,
                        masked_base_seq         => $mseq1,
                        masked_comparison_seq   => $mseq2,
			base_seq_exons		=> $bio_exons,
                        alignment               => $align);

    #
    # If conservation level parameter is specified then also fetched conserved
    # regions (otherwise they must be recomputed).
    #
    # IMPORTANT NOTES
    # - Unfortunately we cannot re-create the conserved regions report since
    #   we don't store all the parameters used to run the conservation analysis
    #   in the oPOSSUM database (such as window size) although we do store the
    #   min. conservation and top percentile) so just set the conserved regions
    #   directly.
    #
    if ($level) {
	my $cra = $self->db->get_ConservedRegionAdaptor;
	if (!$cra) {
	    carp "ERROR getting ConservedRegionAdaptor\n";
	    return;
	}

        my $op_crs = $cra->fetch_list_by_gene_pair_id($gpid, $level);
	if (!$op_crs) {
	    carp "ERROR fetching conserved regions for GenePair $gpid at"
	    		. " conservation level $level\n";
	    return;
	}

	my $fp_crs = _opossum_conserved_regions_to_feature_pairs($op_crs);

	$ca->conserved_regions($fp_crs);
    }

    return $ca;
}

sub _create_bio_seqs
{
    my ($gene_pair, $op_aln) = @_;

    my $seq1 = Bio::LocatableSeq->new(
			-id		=>	"seq1",
    			-alphabet	=>	"dna",
    			-seq		=>	$op_aln->seq1,
			-start		=>	$op_aln->start1,
			-end		=>	$op_aln->end1,
			-strand		=>	1);

    my $seq2 = Bio::LocatableSeq->new(
			-id		=>	"seq2",
    			-alphabet	=>	"dna",
    			-seq		=>	$op_aln->seq2,
			-start		=>	$op_aln->start2,
			-end		=>	$op_aln->end2,
			-strand		=>	1);

    my $mseq1 = Bio::LocatableSeq->new(
			-id		=>	"masked_seq1",
    			-alphabet	=>	"dna",
    			-seq		=>	$op_aln->masked_seq1,
			-start		=>	$op_aln->start1,
			-end		=>	$op_aln->end1,
			-strand		=>	1);

    my $mseq2 = Bio::LocatableSeq->new(
			-id		=>	"masked_seq2",
    			-alphabet	=>	"dna",
    			-seq		=>	$op_aln->masked_seq2,
			-start		=>	$op_aln->start2,
			-end		=>	$op_aln->end2,
			-strand		=>	1);

    my $aligned_seq1 = Bio::LocatableSeq->new(
			-id		=>	"aligned_seq1",
    			-alphabet	=>	"dna",
    			-seq		=>	$op_aln->aligned_seq1,
			-start		=>	$op_aln->start1,
			-end		=>	$op_aln->end1,
			-strand		=>	$op_aln->strand1);

    my $aligned_seq2 = Bio::LocatableSeq->new(
			-id		=>	"aligned_seq2",
    			-alphabet	=>	"dna",
    			-seq		=>	$op_aln->aligned_seq2,
			-start		=>	$op_aln->start2,
			-end		=>	$op_aln->end2,
			-strand		=>	$op_aln->strand2);

    my $align = Bio::SimpleAlign->new();
    $align->add_seq($aligned_seq1);
    $align->add_seq($aligned_seq2);

    return ($seq1, $seq2, $mseq1, $mseq2, $align);
}

sub _opossum_to_bio_exons
{
    my ($op_exons) = @_;

    my @bio_exons;
    foreach my $op_exon (@$op_exons) {
    	push @bio_exons, Bio::SeqFeature::Gene::Exon->new(
				-primary_tag	=> 'exon',
				-source_tag	=> 'oPOSSUM',
				-start		=> $op_exon->rel_start,
				-end		=> $op_exon->rel_end,
				-strand		=> 1);
    }

    return @bio_exons ? \@bio_exons : undef;
}

sub _opossum_conserved_regions_to_feature_pairs
{
    my ($op_crs) = @_;

    return if !$op_crs;

    my @feature_pairs;
    foreach my $op_cr (@$op_crs) {
	my $feature1 = Bio::SeqFeature::Generic->new(
				-start		=> $op_cr->rel_start1,
				-end		=> $op_cr->rel_end1,
				-source_tag	=> 'oPOSSUM',
				-score		=> $op_cr->conservation);

	my $feature2 = Bio::SeqFeature::Generic->new(
				-start		=> $op_cr->rel_start2,
				-end		=> $op_cr->rel_end2,
				-source_tag	=> 'oPOSSUM',
				-score		=> $op_cr->conservation);

    	push @feature_pairs, Bio::SeqFeature::FeaturePair->new(
				-feature1	=> $feature1,
				-feature2	=> $feature2);
    }

    return @feature_pairs ? \@feature_pairs : undef;
}
