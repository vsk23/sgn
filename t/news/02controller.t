use strict;
use warnings FATAL => 'all';

use Data::Dumper;
use Test::More;
use Test::Warn;
use Capture::Tiny 'capture';

use HTML::Entities;
use HTTP::Request;
use HTTP::Request::AsCGI;

use URI::Escape;

use SGN::Context;
use SGN::Controller::News;

use Test::DBIx::Class -config_path => [qw( t news test_news_schema )];

fixtures_ok $_, "loaded $_ fixture"
    for qw| categories stories links |;

my $c = SGN::Context->new;
$c->config->{'DatabaseConnection'}->{'default'} = Schema->storage->connect_info->[0];

my $self = SGN::Controller::News->new( schema => Schema() );

# test form display for adding a new one
{

    my $out = capture_cgi(sub{ $self->display_story_form($c) },
                          HTTP::Request->new( GET => 'http://foo/bar.pl' ),
                         );

  #is( $err, '', 'no warnings' );

  my $now_str = POSIX::strftime( $self->_date_fmt, localtime);
  $now_str =~ s/\d(a|p)m$//i;

  for ( 'Add News Item', 'Date','Headline','id="story_form"','Body', $now_str ) {
      isnt( index($out,$_), -1, "search form contains '$_'" );
  }
}

# test form display for editing an existing one
{
  while( my $story = NewsStory->next ) {

      my $out = capture_cgi(sub{ $self->display_story_form($c) },
                            HTTP::Request->new(GET => 'http://foo/bar.pl?news_story_id='.$story->news_story_id),
                           );

      my $date_str = $story->date->strftime( $self->_date_fmt );
      my @should_contain = (
          'Edit News Item',
          'Date',
          'Headline',
          'id="story_form"',
          'Body',
          $date_str,
          encode_entities($story->headline),
          encode_entities($story->body),
          ( map $_->short_name, NewsCategory->all ),
          map { '"selected">'.$_->short_name } $story->news_categories
         );
      for (@should_contain) {
          isnt( index($out,$_), -1, "search form contains '$_'" )
              #or diag($out);
      }
  }
}

# #test creating a new story via POST
{
    my $test_headline = 'This is the new headline';
    my $test_body     = 'This is the <a href="?foo&bar=2">test</a> body';

    my $created_rs = NewsStory->search({ headline => $test_headline, body => $test_body });
    is( $created_rs->count, 0, 'new story not yet in DB' );

    my $now_str = POSIX::strftime( $self->_date_fmt, localtime);
    my $req = HTTP::Request->new(POST => 'http://sgn.localhost.localdomain/news/story_crud.pl');
    $req->content_type('application/x-www-form-urlencoded');
    $req->content(join '&',
                    map { join '=', $_->[0], uri_escape($_->[1]) }
                        [ date => $now_str ],
                        [ back_to => '/test/back/to' ],
                        [ headline => $test_headline ],
                        [ body     => $test_body     ],
                        [ op       => 'create'       ],
                 );
#     use LWP;
#     LWP::UserAgent->new->request($req);
#     die 'break';
    my $out = capture_cgi(sub{ $self->create_update_story($c) },
                          $req
                         );

    TODO: { local $TODO = 'HTTP::Request::AsCGI does not work right';
            is( $out, 'foo' );

            is( $created_rs->count, 1, 'created a new story OK' );
        }
}


{ # test AsCGI


    my %data = (
        foo => 'bar',
       );

    my $req = HTTP::Request->new(POST => 'http://fake/url');
    $req->content_type('application/x-www-form-urlencoded');
    $req->content(join '&',
                    map { join '=', map uri_escape($_), $_, $data{$_} }
                        keys %data
                 );

    my $out;
    warning_is {
        my $c = HTTP::Request::AsCGI->new($req)->setup;
        print Dumper( { CGI->new->Vars } );

        $out = $c->stdout;
    } undef, 'no warnings';

    local $/;
    $out = scalar <$out>;

  TODO: { local $TODO = 'HTTP::Request::AsCGI does not work right';
          is( $out, Dumper(\%data), 'post round-trip' );
      }
}



done_testing;

sub capture_cgi {
    my $sub = shift;
    my $request = shift;

    my $out;
    warning_is {
        my $c = HTTP::Request::AsCGI->new($request)->setup;
        $sub->();

        $out = $c->stdout;
    } undef, 'no warnings';

    local $/;
    return scalar <$out>;
}

