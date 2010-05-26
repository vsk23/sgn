use strict;
use warnings FATAL => 'all';

use Test::More;
use Capture::Tiny 'capture';

use SGN::Context;
use SGN::Controller::News;

use Test::DBIx::Class -config_path => [qw( t news test_news_schema )];

fixtures_ok $_, "loaded $_ fixture"
    for qw| categories stories links |;

my $c = SGN::Context->new;
$c->config->{'DatabaseConnection'}->{'default'} = Schema->storage->connect_info->[0];

my $self = SGN::Controller::News->new( schema => Schema() );

{ my ($out,$err) = capture{ $self->display_story_form($c) };
  is( $err, '', 'no warnings' );

  my $now_str = POSIX::strftime( $self->_date_fmt, localtime);
  $now_str =~ s/\d(a|p)m$//i;

  isnt( index($out,$_), -1, "search form contains '$_'" )
      for 'Add News Item', 'Date','Headline','id="story_form"','Body', $now_str;
}

done_testing;
