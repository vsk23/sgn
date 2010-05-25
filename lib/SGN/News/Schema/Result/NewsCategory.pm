package SGN::News::Schema::Result::NewsCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

SGN::News::Schema::Result::NewsCategory

=cut

__PACKAGE__->table("news_category");

=head1 ACCESSORS

=head2 news_category_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'news_category_news_category_id_seq'

=head2 short_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 long_name

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "news_category_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "news_category_news_category_id_seq",
  },
  "short_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "long_name",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("news_category_id");
__PACKAGE__->add_unique_constraint("news_category_short_name_key", ["short_name"]);

=head1 RELATIONS

=head2 news_story_categories

Type: has_many

Related object: L<SGN::News::Schema::Result::NewsStoryCategory>

=cut

__PACKAGE__->has_many(
  "news_story_categories",
  "SGN::News::Schema::Result::NewsStoryCategory",
  { "foreign.news_category_id" => "self.news_category_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 12:30:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OnUPvGMPmnlHvVphTfJZVQ

__PACKAGE__->many_to_many(
    'news_stories',
    'news_story_categories' => 'news_story',
   );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
