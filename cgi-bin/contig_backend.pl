#!/usr/bin/perl

use strict;
use JSON;

print "Content-Type: text/plain\n\n";




use strict;
use warnings;


use CXGN::BioTools::AceTools;
use CXGN::BioTools::GffTools;


use FileHandle;



## get location by id

##obtain information

## encode into json

## Directories ## - have them preset to something?
my $data_dir ="/home/vsk23/cxgn/data/ace_files/Nspecies_snp.ace";  # ACE FILE
my $index_dir="/home/vsk23/cxgn/data/index_files/Nspecies_snp_index.db";  #DO i need this?
my $contig_id = "step3_c3";   # test contig id
my $contig_id2 = "step3_c10"; # test2 contig id
my $index_dir2= "/home/vsk23/cxgn/data/ace_files/hashtables/Nspecies_snpgff_indx.db";
my $new_gff_dir = "/home/vsk23/cxgn/data/gff_files/Nspecies_snpgff";
my $tab_dir = "/home/vsk23/cxgn/data/tab_files/Nspecies.tab";

my $json = JSON->new();

## TESTING build_ace_hash_file ##
my $tester_hash = CXGN::BioTools::AceTools-> build_ace_hash_file($data_dir, $index_dir);

## TESTING convert_ace_to_gff ##
#Bio::Assembly::AceTools->convert_ace_to_gff($data_dir,$new_gff_dir, $index_dir, $tab_dir,$tester_hash);

## TESTING get_location_by_id ###
my $byte_loc =CXGN::BioTools::AceTools-> get_location_by_id($contig_id,$tester_hash);
#print "$byte_loc \n";
my $byte_loc2 = CXGN::BioTools::AceTools-> get_location_by_id($contig_id2, $tester_hash);


## TESTING get_seq_by_location ##

my $contig_info = CXGN::BioTools::AceTools->get_seq_by_location($byte_loc, $data_dir, $contig_id);
#my $contig_info2 = Bio::Assembly::AceTools->get_seq_by_location($byte_loc2, $data_dir, $contig_id2);


##process and draw graph

my @depth;
my @sequence;

#initialize depth &sequence

for (my $count =0; $count< $contig_info->{$contig_id."_length"}; $count++){
             $sequence[$count] = $count;
             $depth[$count] = 0;   
    }


while( my ($id, $value) = each %$contig_info ) {
    if($id =~ m/_sc/){
	 if($value =~  m/\S?(\d+)\-(\d+)\S?/){
	   #  print STDERR "$value \n";
	     my $read_start = $1;
	    my $read_length = $2;
	    
	     for(my $i=$read_start;$i<=$read_length;$i++){

		 $depth[$i]+=1;
		# print STDERR "$depth[$i] \n";
	     }

	 }
    }
}


##draw plot



my $jobj = $json->encode($contig_info);
#print "Content-Type: text/plain\n\n";
print "$jobj";
