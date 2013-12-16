#!/usr/bin/perl

#use lib "/opt/ensembl_ucsc/ensembl/modules";

use Bio::EnsEMBL::Registry;

use strict;


sub getFeatureInfo
{
	# Routine to get 
    my $feature = shift;

    my $stable_id  = $feature->stable_id();
    my $seq_region = $feature->slice->seq_region_name();
    my $start      = $feature->seq_region_start();
    my $stop        = $feature->seq_region_end();
    my $strand     = $feature->seq_region_strand();
    
    my $newstrand=".";
    if($strand==1){
        $newstrand="+";
    }elsif($strand==-1){
        $newstrand="-";
    }
    
    #print "$stanble_id::$seq_region::$start::$stop::$strand\n";

    return ($stable_id, $seq_region, $start, $stop, $newstrand );
}


sub writeGeneIDs
{
    # Read in the arguments for the subroutine	
	my($inputFile,$outputFile,$species,$ensHost,$ensPort,$ensUsr,$ensPasswd)=@_;
	
	my $shortSpecies="";
	if($species eq "Rat"){
	    $shortSpecies="Rn";
	}else{
	    $shortSpecies="Mm";
	}
        
        
    # connect to Ensembl through Perl API
    # connecting to a closer server dramatically increases performance
    my $registry = 'Bio::EnsEMBL::Registry';

	my $dbAdaptorNum=-1;
	my $ranEast=0;
	
        #try local connection
	eval{
	    print "try local\n";
	    $dbAdaptorNum =$registry->load_registry_from_db(
		-host => $ensHost, #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
		-port => $ensPort,
		-user => $ensUsr,
		-pass => $ensPasswd
	    );
	    print "local finished:$dbAdaptorNum\n";
	    1;
	}or do{
	    print "local ensembl DB is unavailable\n";
	    $dbAdaptorNum=-1;
	};
        #try mirrored location
	if($dbAdaptorNum==-1){
	    $ranEast=1;
	    eval{
		    $dbAdaptorNum=$registry->load_registry_from_db(
			-host => 'useastdb.ensembl.org', #'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
			-port => 5306,
			-user => 'anonymous'
		    );
		    print "east mirror finished:$dbAdaptorNum\n";
		    1;
	    }or do{
		print "ensembl east DB is unavailable\n";
		$dbAdaptorNum=-1;
	    };
	}
        #if all else fails generally due to version of API try main server
	if($ranEast==1 && $dbAdaptorNum<1){
	    print "try main\n";
	    # Enable this option if problems occur connecting the above option is faster, but only has current and previous versions of data
	    $dbAdaptorNum=$registry->load_registry_from_db(
		-host => 'ensembldb.ensembl.org', 
		-user => 'anonymous'
	    );
	    print "main finished:$dbAdaptorNum\n";
	}
        
        my $slice_adaptor = $registry->get_adaptor( $species, 'core', 'Slice' );
        
        open IN, '<'.$inputFile or die "Could not open file $inputFile";
        open OUT,'>'.$outputFile or die "Could not open file $outputFile";
        
        while(my $line=<IN>){
            my @tabs=split(/\t/,$line);
            my $chr=$tabs[1];
            my $minCoord=$tabs[2];
            my $maxCoord=$tabs[3];
            my $strand=$tabs[4];
            $strand =~ s/\s+$//;
            my $tcID=$tabs[0];
            my $tmpslice = $slice_adaptor->fetch_by_region('chromosome', $chr,$minCoord,$maxCoord);
            my $genes = $tmpslice->get_all_Genes();
            my $count=0;
            while(my $tmpgene=shift @{$genes}){
                my ($geneName, $geneRegion, $geneStart, $geneStop,$geneStrand) = getFeatureInfo($tmpgene);
                my $geneExternalName =$tmpgene->external_name();
		my $geneDescription  =$tmpgene->description();
                #print "$geneName\t$geneStrand\t\t$tcID\t$strand";
                if($strand eq $geneStrand){
                    my $overLapTC=0.0;
                    my $overLapG=0.0;
                    my $maxStart=$geneStart;
                    if($minCoord>$geneStart){
                        $maxStart=$minCoord;
                    }
                    my $minEnd=$geneStop;
                    if($maxCoord<$geneStop){
                        $minEnd=$maxCoord;
                    }
                    my $overlapLen=$minEnd-$maxStart;
                    my $tcLen=$maxCoord-$minCoord;
                    my $geneLen=$geneStop-$geneStart;
                    if($overlapLen>0){
                        $overLapTC=$overlapLen/$tcLen*100;
                        $overLapG=$overlapLen/$geneLen*100;
                        #print "overlapLen=$overlapLen  overLap=$overLapTC  $overLapG\n";
                    }
                    if(($overLapTC>=50.0 and $overLapG>=30.0) or ($overLapG>=50.0 and $overLapTC>=30.0)){
                        $count++;
                        print OUT "$tcID\t$geneName\t$geneExternalName\t$geneStart\t$geneStop\t$overLapTC\t$overLapG\t$geneDescription\n";   
                    }
                }else{
                    #print "\tnot equal\n";
                }
                
            }
            #print "$tcID\t #genes=$count\n";
        }
        close OUT;
        close IN;
        
        
}

        my $arg1 = $ARGV[0]; # input file
	my $arg2 = $ARGV[1]; # output file
	my $arg3 = $ARGV[2]; # species
	my $arg4 = $ARGV[3]; # ens host
	my $arg5 = $ARGV[4]; #ens port
	my $arg6 = $ARGV[5]; # ens user
	my $arg7 = $ARGV[6]; # ens password
	
	writeGeneIDs($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7);
1;