#!/usr/bin/perl

use Bio::EnsEMBL::Registry;

sub extractUpstream
{	
	my( $input,$output,$type,$len,$ensHost,$ensPort,$ensUsr,$ensPasswd)=@_;
        
        my $species="Mouse";
        my @genelist=();

        #read input gene list
        open IN, "<",$input;
        while(<IN>){
            my $line=$_;
            #print $line;
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;
            push (@genelist,$line);
        }
        close IN;

        if(index($genelist[0],"ENSRNO")>-1){
            $species="Rat";
        }

	#
	# Using perl API to read data from ensembl
	#
	#
	
	my $registry = 'Bio::EnsEMBL::Registry';

	my $dbAdaptorNum=-1;
	my $ranEast=0;
	
	eval{
	    print "try local\n";
	    $dbAdaptorNum =$registry->load_registry_from_db(
		-host => $ensHost,
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
	if($dbAdaptorNum==-1){
	    $ranEast=1;
	    eval{
		    $dbAdaptorNum=$registry->load_registry_from_db(
			-host => 'useastdb.ensembl.org',
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
	if($ranEast==1 && $dbAdaptorNum<1){
	    print "try main\n";
	    # Enable this option if problems occur connecting the above option is faster, but only has current and previous versions of data
	    $dbAdaptorNum=$registry->load_registry_from_db(
		-host => 'ensembldb.ensembl.org', 
		-user => 'anonymous'
	    );
	    print "main finished:$dbAdaptorNum\n";
	}
	
	open OUT,">",$output;

	#print "connected\n";
        my $geneAdaptor= $registry->get_adaptor( $species, 'core', 'gene' );
	my $slice_adaptor = $registry->get_adaptor( $species, 'core', 'Slice' );
        my $seq_adaptor = $registry->get_adaptor( $species, 'core', 'Sequence' );
	my $seq="";
        my $name=">";
	foreach my $gene(@genelist){
            if(length($gene)>0){
                my $seq="";
                
                my @list=split(";",$gene);
                #print $gene."\n";
                my $ensG=$geneAdaptor->fetch_by_stable_id($list[0]);
                if($type eq 'gene'){
                    my $name="";
                    $name=$list[0];
                    if(@list>1){
                        $name=$name." | GeneListIDs ".$list[1];
                    }
                    my $start=$ensG->seq_region_start()-$len;
                    my $stop=$ensG->seq_region_start();
                    if($ensG->strand() == -1){
                        $start=$ensG->seq_region_end();
                        $stop=$ensG->seq_region_end()+$len;
                    }
                    if($start<1){
                        $start=1;
                    }
                    #print "start:".$ensG->seq_region_start()."\tstop:".$ensG->seq_region_end()."\t strand:".$ensG->strand()."\n";
                    #print "seq=".$start."-".$stop."\t".$ensG->seq_region_name()."\n";
                    my $ensGSlice=$slice_adaptor->fetch_by_region('chromosome', $ensG->seq_region_name(), $start, $stop ,$ensG->strand());
                    $seq=${$seq_adaptor->fetch_by_Slice_start_end_strand($ensGSlice)};
                    #print "Seq:".$seq."\n";
                    if(not($seq eq "")){
                        print OUT ">".$name."\n";
                        print OUT $seq."\n";
                    }
                }else{
                    my $transcripts=$ensG->get_all_Transcripts ();
                    #print "gene start:".$ensG->seq_region_start()."\tstop:".$ensG->seq_region_end()."\t strand:".$ensG->strand()."\n";
                    $cntTranscripts = 0;
		    while ( my $transcript = shift @{$transcripts} ) {
                        my $initStart=$transcript->seq_region_start();
                        my $initStop=$transcript->seq_region_end();
                       
                        if($type eq "trxcds"){
                            $initStart=$transcript->coding_region_start();
                            $initStop=$transcript->coding_region_end();
                        }
                        #print "coding:".$initStart."-".$initStop."\n";
                        my $start=$initStart-$len;
                        my $stop=$initStart;
                        if($ensG->strand() == -1){
                            $start=$initStop;
                            $stop=$initStop+$len;
                        }
                        if($start<1){
                            $start=1;
                        }
                        #print $transcript->stable_id()."\n".$ensG->seq_region_name().":".$start."-".$stop."\n";
                        my $ensTSlice=$slice_adaptor->fetch_by_region('chromosome', $ensG->seq_region_name(), $start, $stop ,$ensG->strand());
                        $seq="";
                        $seq=${$seq_adaptor->fetch_by_Slice_start_end_strand($ensTSlice)};
                        if(not($seq eq "")){
                            my $name=$list[0]." | ".$transcript->stable_id();
                            if(@list>1){
                                $name=$name." | GeneListIDs ".$list[1];
                            }
                            print OUT ">".$name."\n";
                            print OUT $seq."\n";
                        }
                    }

                    
                }
                
            }
        }	

        close OUT;
}
#
#	
	my $arg1 = $ARGV[0]; # Ensembl ID Gene List
	my $arg2 = $ARGV[1]; # Output file
	my $arg3 = $ARGV[2]; # type
	my $arg4 = $ARGV[3]; # extraction length
	my $arg5 = $ARGV[4]; # ens host
	my $arg6 = $ARGV[5]; # ens port
        my $arg7 = $ARGV[6]; # ens user
	my $arg8 = $ARGV[7]; # ens password
	extractUpstream($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8);


exit 0;