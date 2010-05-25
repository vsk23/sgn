package SGN::News::Schema::Result::NewsStory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

SGN::News::Schema::Result::NewsStory

=cut

__PACKAGE__->table("news_story");

=head1 ACCESSORS

=head2 news_story_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'news_story_news_story_id_seq'

=head2 headline

  data_type: 'text'
  is_nullable: 0

=head2 body

  data_type: 'text'
  is_nullable: 0

=head2 date

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "news_story_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "news_story_news_story_id_seq",
  },
  "headline",
  { data_type => "text", is_nullable => 0 },
  "body",
  { data_type => "text", is_nullable => 0 },
  "date",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);
__PACKAGE__->set_primary_key("news_story_id");
__PACKAGE__->add_unique_constraint("news_story_headline_key", ["headline", "date"]);

=head1 RELATIONS

=head2 news_story_categories

Type: has_many

Related object: L<SGN::News::Schema::Result::NewsStoryCategory>

=cut

__PACKAGE__->has_many(
  "news_story_categories",
  "SGN::News::Schema::Result::NewsStoryCategory",
  { "foreign.news_story_id" => "self.news_story_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 14:46:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m9ilrGbc+GDHkVgOGfdx4w

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->add_columns(
    date => { data_type => 'datetime' }
   );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
