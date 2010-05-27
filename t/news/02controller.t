use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Warn;
use Capture::Tiny 'capture';


use HTML::Entities;
use HTTP::Request;
use HTTP::Request::AsCGI;

use SGN::Context;
use SGN::Controller::News;

use Test::DBIx::Class -config_path => [qw( t news test_news_schema )];

fixtures_ok $_, "loaded $_ fixture"
    for qw| categories stories links |;

my $c = SGN::Context->new;
$c->config->{'DatabaseConnection'}->{'default'} = Schema->storage->connect_info->[0];

my $self = SGN::Controller::News->new( schema => Schema() );

# test form display for adding a new one
{ my $out = capture_cgi(sub{ $self->display_story_form($c) },
                        GET => 'http://foo/bar.pl'
                       );

  #is( $err, '', 'no warnings' );

  my $now_str = POSIX::strftime( $self->_date_fmt, localtime);
  $now_str =~ s/\d(a|p)m$//i;

  for ( 'Add News Item', 'Date','Headline','id="story_form"','Body', $now_str ) {
      isnt( index($out,$_), -1, "search form contains '$_'" );
  }
}

# test form display for editing an existing form one
{
  while( my $story = NewsStory->next ) {
      my $out = capture_cgi(sub{ $self->display_story_form($c) },
                            GET => 'http://foo/bar.pl?news_story_id='.$story->news_story_id
                           );

      my $date_str = $story->date->strftime( $self->_date_fmt );
      for ( 'Edit News Item', 'Date','Headline','id="story_form"','Body', $date_str, encode_entities($story->headline), encode_entities($story->body) ) {
          isnt( index($out,$_), -1, "search form contains '$_'" )
              or diag($out);
      }
  }
}

done_testing;

sub capture_cgi {
    my $sub = shift;

    my $request = HTTP::Request->new( @_ );

    my $out;
    warning_is {
        my $c = HTTP::Request::AsCGI->new($request)->setup;
        $sub->();

        $out = $c->stdout;
    } undef, 'no warnings';

    local $/;
    return scalar <$out>;
}

