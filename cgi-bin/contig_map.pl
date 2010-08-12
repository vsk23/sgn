

use strict;
use warnings;

use CXGN::Metadata::Schema;
use SGN::Context;


#my $c = SGN::Context->new();

###print "Content-type: text/html\n\n";

#--- Connect to proper schema
my $schema = $c->dbic_schema('CXGN::Metadata::Schema');
#--- Get ResultSet for proper table ( containing file directories )
my $directories = $schema->resultset('MdFiles');
#--- Get ResultSet for data,index, and tab file
my $data_rset = $directories->search({basename => 'Nspecies_snp.ace'});
my $index_rset = $directories->search({basename => 'Nspecies_snp_index.db'});
my $tab_index_rset = $directories->search({basename => 'tabindex.db'});
my $data_info = $data_rset->next;

#--- Build file paths based on result set
my $data_file = ($data_info->dirname)."/".($data_info->basename);
my $index_file = (($index_rset->next)->dirname)."/Nspecies_snp_index.db";
my $contig_id = "step3_c99";
my $temp_dir = "/home/vsk23/cxgn/sgn/documents/tempfiles/temp_images"; #FIX THIS use get_conf..
my $tab_index_file = (($tab_index_rset->next)->dirname)."/tabindex.db";

#--- Call mason component
$c->forward_to_mason_view("/contig_map.mas" , data_file=>$data_file, index_file=>$index_file, contig_id=>$contig_id, temp_dir=>$temp_dir, tab_index_file=>$tab_index_file);
