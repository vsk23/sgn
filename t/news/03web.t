use strict;
use warnings FATAL => 'all';

use POSIX;

use Test::More;
use Test::WWW::Mechanize;

use SGN::Controller::News;

my $urlbase     = "$ENV{SGN_TEST_SERVER}/news/story_crud.pl";
my $crud_script = "$ENV{SGN_TEST_SERVER}/news/story_crud.pl";

my $mech = Test::WWW::Mechanize->new;
$mech->get_ok( $crud_script );

# add a test category if one is not already present
my @harness_category_ids = ensure_harness_categories($mech);

# check getting the search form
{ my $now_str = POSIX::strftime( SGN::Controller::News->_date_fmt, localtime);
  $now_str =~ s/\d(a|p)m$//i;

  $mech->content_contains($_)
      for 'Add News Item', 'Date', $now_str, 'Body', 'Headline','id="story_form"';
}

# test adding a new story
{
    my $now_str = POSIX::strftime( SGN::Controller::News->_date_fmt, localtime);
    $mech->submit_form_ok({
        form_name => 'story_form',
        fields => {
            date     => $now_str,
            op       => 'create',
            headline => 'Test headline (timestamp '.$now_str.')',
            body     => 'This is a test news story created by the test harness, running on '
                        .`hostname -s`
                        .' by '.getpwuid($>)
                        .' at '.$now_str,
            back_to  => '/',
            news_categories => [ @harness_category_ids[2,3] ],
           },
    });

    $mech->content_contains('Image of the week');

}

done_testing;


sub ensure_harness_categories {
    my $mech = shift;
    foreach my $catnum (1..4) {
        my $catname = 'Test Category '.$catnum;
        while( -1 == index($mech->content,">$catname</option>") ) {
            die 'test harness category not present, cannot test';
            # TODO: write code to insert a test harness category
        }
    }

    return (1,2,3,4);
}
