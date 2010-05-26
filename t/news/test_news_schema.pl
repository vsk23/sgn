{
    schema_class => 'SGN::News::Schema',
    fixture_class => '::Populate',

    connect_info => ["dbi:SQLite:dbname=:memory:","",""],
    fixture_path => ["t","news","fixtures"],
    resultsets => [qw[ NewsStory  NewsCategory ]],

#     fixture_sets => {
#         complete => [qw( stories categories links )],
#        },
}
