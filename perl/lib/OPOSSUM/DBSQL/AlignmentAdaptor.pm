=head1 NAME

OPOSSUM::DBSQL::AlignmentAdaptor - Adaptor for MySQL queries to retrieve and
store Alignment objects.

=head1 SYNOPSIS

$aa = $db_adaptor->get_AlignmentAdaptor();

=head1 DESCRIPTION

The alignments table of the oPOSSUM database stores the raw, masked and
aligned sequences of the two species.

=head1 AUTHOR

 David Arenillas
 Wasserman Lab
 Centre for Molecular Medicine and Therapeutics
 University of British Columbia

 E-mail: dave@cmmt.ubc.ca

=head1 METHODS

=cut

package OPOSSUM::DBSQL::AlignmentAdaptor;

use strict;

use Carp;

use OPOSSUM::DBSQL::BaseAdaptor;
use OPOSSUM::Alignment;

use vars '@ISA';
@ISA = qw(OPOSSUM::DBSQL::BaseAdaptor);

=head2 new

 Title   : new
 Usage   : $aa = OPOSSUM::DBSQL::AlignmentAdaptor->new($db_adaptor);
 Function: Construct a new AlignmentAdaptor object
 Args    : An OPOSSUM::DBSQL::DBAdaptor object
 Returns : a new OPOSSUM::DBSQL::AlignmentAdaptor object

=cut

sub new
{
    my ($class, @args) = @_;

    $class = ref $class || $class;

    my $self = $class->SUPER::new(@args);

    return $self;
}

#=head2 fetch_by_alignment_id
#
# Title   : fetch_by_alignment_id
# Usage   : $alignment = $aa->fetch_by_alignment_id($id);
# Function: Fetch an Alignment object from the DB using it's ID.
# Args    : The Alignment ID.
# Returns : An OPOSSUM::Alignment object.
#
#=cut
#
#sub fetch_by_alignment_id
#{
#    my ($self, $id) = @_;
#
#    my $sql = qq{select
#			alignment_id,
#			gene_pair_id,
#			start1,
#			start2,
#			end1,
#			end2,
#			truncated1,
#			truncated2,
#			seq1,
#			seq2,
#			masked_seq1,
#			masked_seq2,
#			aligned_seq1,
#			aligned_seq2
#		from alignments
#		where alignment_id = $id
#	    };
#
#    my $sth = $self->prepare($sql);
#    if (!$sth) {
#	carp "error fetching alignment with alignment_id = $id\n"
#		. $self->errstr;
#	return;
#    }
#
#    if (!$sth->execute) {
#	carp "error fetching alignment with alignment_id = $id\n"
#		. $self->errstr;
#	return;
#    }
#
#    my $alignment;
#    if (my @row = $sth->fetchrow_array) {
#	$alignment = OPOSSUM::Alignment->new(
#	    				-id		=> $row[0],
#	    				-gene_pair_id	=> $row[1],
#	    				-start1		=> $row[2],
#	    				-start2		=> $row[3],
#	    				-end1		=> $row[4],
#	    				-end2		=> $row[5],
#	    				-truncated1	=> $row[6],
#	    				-truncated2	=> $row[7],
#	    				-seq1		=> $row[8],
#	    				-seq2		=> $row[9],
#	    				-masked_seq1	=> $row[10],
#	    				-masked_seq2	=> $row[11],
#	    				-aligned_seq1	=> $row[12],
#	    				-aligned_seq2	=> $row[13]);
#    }
#    $sth->finish;
#
#    return $alignment;
#}

=head2 fetch_by_gene_pair_id

 Title   : fetch_by_gene_pair_id
 Usage   : $alignment = $aa->fetch_by_gene_pair_id($gpid);
 Function: Fetch an Alignment object from the DB using it's gene pair ID.
 Args    : The GenePair ID.
 Returns : An OPOSSUM::Alignment object.

=cut

sub fetch_by_gene_pair_id
{
    my ($self, $gpid) = @_;

    my $sql = qq{select
			gene_pair_id,
			chr1,
			chr2,
			start1,
			start2,
			end1,
			end2,
			strand1,
			strand2,
			seq1,
			seq2,
			masked_seq1,
			masked_seq2,
			aligned_seq1,
			aligned_seq2
		from alignments
		where gene_pair_id = $gpid
	    };

    my $sth = $self->prepare($sql);
    if (!$sth) {
	carp "error fetching alignment with gene_pair_id = $gpid\n"
		. $self->errstr;
	return;
    }

    if (!$sth->execute) {
	carp "error fetching alignment with gene_pair_id = $gpid\n"
		. $self->errstr;
	return;
    }

    my $alignment;
    if (my @row = $sth->fetchrow_array) {
	$alignment = OPOSSUM::Alignment->new(
	    				-gene_pair_id	=> $row[0],
	    				-chr1		=> $row[1],
	    				-chr2		=> $row[2],
	    				-start1		=> $row[3],
	    				-start2		=> $row[4],
	    				-end1		=> $row[5],
	    				-end2		=> $row[6],
	    				-strand1	=> $row[7],
	    				-strand2	=> $row[8],
	    				-seq1		=> $row[9],
	    				-seq2		=> $row[10],
	    				-masked_seq1	=> $row[11],
	    				-masked_seq2	=> $row[12],
	    				-aligned_seq1	=> $row[13],
	    				-aligned_seq2	=> $row[14]);
    }
    $sth->finish;

    return $alignment;
}

=head2 store

 Title   : store
 Usage   : $id = $aa->store($alignment);
 Function: Store alignment in the database.
 Args    : The alignment (OPOSSUM::Alignment) to store
 Returns : True on success, false otherwise.

=cut

sub store
{
    my ($self, $alignment) = @_;

    if (!ref $alignment || !$alignment->isa('OPOSSUM::Alignment')) {
    	carp "Not an OPOSSUM::Alignment object";
	return;
    }

    my $sql = qq{insert into alignments (
		    gene_pair_id,
		    chr1,
		    chr2,
		    start1,
		    start2,
		    end1,
		    end2,
		    strand1,
		    strand2,
		    seq1,
		    seq2,
		    masked_seq1,
		    masked_seq2,
		    aligned_seq1,
		    aligned_seq2)
		values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)};

    my $sth = $self->prepare($sql);
    if (!$sth) {
    	carp "Error preparing insert alignment statement - "
		. $self->errstr . "\n";
	return;
    }

    if (!$sth->execute( $alignment->gene_pair_id,
    			$alignment->chr1,
    			$alignment->chr2,
    			$alignment->start1,
    			$alignment->start2,
    			$alignment->end1,
    			$alignment->end2,
    			$alignment->strand1,
    			$alignment->strand2,
    			$alignment->seq1,
    			$alignment->seq2,
			$alignment->masked_seq1,
			$alignment->masked_seq2,
			$alignment->aligned_seq1,
			$alignment->aligned_seq2))
    {
    	carp "Error inserting alignment - " . $self->errstr . "\n";
	return 0;
    }

    return 1;
}

1;
