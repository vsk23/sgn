package SGN::News::Schema::Result::NewsStoryCategory;

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SGN::News::Schema::Result::NewsStoryCategory

=cut

__PACKAGE__->table("news_story_category");

=head1 ACCESSORS

=head2 news_story_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 news_category_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "news_story_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "news_category_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 RELATIONS

=head2 news_category

Type: belongs_to

Related object: L<SGN::News::Schema::Result::NewsCategory>

=cut

__PACKAGE__->belongs_to(
  "news_category",
  "SGN::News::Schema::Result::NewsCategory",
  { news_category_id => "news_category_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 news_story

Type: belongs_to

Related object: L<SGN::News::Schema::Result::NewsStory>

=cut

__PACKAGE__->belongs_to(
  "news_story",
  "SGN::News::Schema::Result::NewsStory",
  { news_story_id => "news_story_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->add_unique_constraint("news_story_category_unique", ["news_story_id","news_category_id"]);

1;
