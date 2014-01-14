#!/usr/bin/perl
use strict;

use Bio::EnsEMBL::Registry;

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}



sub readEnsemblSeqFromDB{
	my($chromosome,$species,$minCoord,$maxCoord,$ensDsn,$ensUsr,$ensPasswd)=@_;
	my $registry = 'Bio::EnsEMBL::Registry';
	$registry->load_registry_from_db(
		-host => '140.226.114.31', #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
		-port => 3306,
		-user => $ensUsr,
		-pass => $ensPasswd
	    );

	my $seq_adaptor = $registry->get_adaptor( $species, 'core', 'Sequence' );
	my $slice_adaptor = $registry->get_adaptor($species, 'core','Slice');
	my $slice=$slice_adaptor->fetch_by_region('chromosome', $chromosome,  $minCoord,$maxCoord,"+");
	my $longSeq=${$seq_adaptor->fetch_by_Slice_start_end_strand($slice)};
	return $longSeq;
}
1;

