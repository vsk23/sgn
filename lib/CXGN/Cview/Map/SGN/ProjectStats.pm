
use strict;

package CXGN::Cview::Map::SGN::ProjectStats;

use base qw | CXGN::Cview::Map |;

use CXGN::People::BACStatusLog;
use CXGN::Cview::Chromosome::Glyph;


sub new { 
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->set_chromosome_names("1", "2", "3", "4", "5", "6", "7", "8", "9" ,"10", "11", "12");
    $self->set_chromosome_lengths( (100)x12 );
    $self->set_chromosome_count(12);
    $self->set_short_name("Tomato Sequencing");
    $self->set_long_name("Tomato Sequencing Statistics by Chromosome");
    $self->set_type("project_overview");
    $self->set_units("%");
    $self->set_preferred_chromosome_width(12);
    return $self;
}

sub get_chromosome { 
    my $self = shift;
    my $chr_nr = shift;

    print STDERR "Now dealing with chr $chr_nr !\n";
    my $bac_status_log=CXGN::People::BACStatusLog->new($self->get_dbh());
    my @c_len = $self->get_chromosome_lengths();
    my @c_percent_finished = $bac_status_log->get_chromosomes_percent_finished();
    
    print STDERR "Chromosome percent finished: ".(join " ", @c_percent_finished)."\n";

    my $c= CXGN::Cview::Chromosome::Glyph -> new(1, 100, 40, 40);
    my $m = CXGN::Cview::Marker->new($c);
    $m -> set_offset($c_percent_finished[$chr_nr]);
    $m -> hide();
    $c->add_marker($m);
    $c->set_caption($chr_nr);
    $c->set_height($c_len[$chr_nr-1]);
    
    print STDERR "Now generating chr $chr_nr with $c_percent_finished[$chr_nr] \% finished.\n";
    $c->set_fill_level($c_percent_finished[$chr_nr]);
    $c->set_bac_count(0);
    
    return $c;
}


return 1; 
    

