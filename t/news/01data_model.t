use strict;
use warnings;

use Test::More;

use Test::DBIx::Class -config_path => [qw( t news test_news_schema )];

fixtures_ok 'stories', 'loaded stories';

my $jimmy = NewsStory->search({headline => { like => 'Jimmy%' }})->single;
can_ok( $jimmy, 'date' );
can_ok( $jimmy->date, 'ymd' ); #< dates are inflated

fixtures_ok 'categories', 'loaded categories';

is( NewsCategory->search({short_name => 'Loved Tomatoes'})->count, 1, 'found the tomatoes category' );

is( NewsCategory->search_related('news_story_categories')->count, 0, 'no links between categories and stories 1' );
is( NewsStory->search_related('news_story_categories')->count, 0, 'no links between categories and stories 2' );

fixtures_ok 'links', 'loaded links';


is( NewsStory->search_related('news_story_categories')
             ->search_related('news_category')
             ->count,
    4,
    'got links' );

done_testing;
