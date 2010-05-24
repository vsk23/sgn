package SGN::News::Schema::Result::NewsStoryCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 12:30:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DJZbMZyE51KuextLEDc0RQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
