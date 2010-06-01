package SGN::Controller::News;
use Moose;
use warnings FATAL => 'all';
use namespace::autoclean;

use Carp qw/ confess /;

use HTML::FormFu;

use SGN::News::Schema;

use YAML ();


has 'schema' => (
    is       => 'ro',
    required => 1,
    isa => 'DBIx::Class::Schema',
);

# the HTML::FormFu form that we use for editing news stories
sub _build_story_form {
    my ($self,$c) = @_;
    $c or confess 'must pass c';

    my $date_fmt = $self->_date_fmt;
    my $form = HTML::FormFu->new(YAML::Load(<<EOY));
      method: POST
      attributes:
        name: story_form
      model_config:
        resultset: NewsStory
      elements:
          - type: Text
            name: date
            label: Date
            inflators:
               - type: DateTime
                 parser:
                   strptime: '$date_fmt'
                 strptime:
                   pattern: '\%F \%H:\%M'

          - type: Hidden
            name: news_story_id

    # form carries hidden state variables op (operation) and back_to
          - type: Hidden
            name: op
          - type: Hidden
            name: back_to

          - type: Text
            name: headline
            label: Headline
            size: 60

          - type: Textarea
            cols: 50
            rows: 5
            label: Body
            name: body

          - type: Select
            multiple: 1
            label: Categories
            name: news_categories
            model_config:
              resultset: NewsCategory
              label_column: short_name

          - type: Submit
            name: submit
EOY

    # a back-to url in the form, and the default date of right now (server time)
    $form->default_values({
        back_to => $self->_back_to($c),
        date   => lc DateTime->now( time_zone => 'local' )->strftime( $date_fmt ),
       });

    $form->stash->{schema} = $self->schema;

    return $form;
}
sub _back_to {
    my ($self, $c) = @_;
    my $back_to_url = $c->req->param('back_to') || $c->req->url( -relative => 1 );
    $back_to_url =~ s|://||; #< foil any cross-site redirecting
    return $back_to_url;
}

sub create_update_story {
    my ($self, $c ) = @_;

    my $form = $self->_build_story_form($c);
    $form->process( $c->req );

    if( $form->submitted_and_valid ) {
        no warnings 'numeric', 'uninitialized';
        if( my $story = $self->_story_rs->find( $form->param_value('news_story_id') + 0)) {
            $form->model->update( $story );
        } else {
            $form->model->create;
        }
        $c->req->redirect( $self->_back_to($c) );
    } else {
        $self->display_story_form($c,$form);
    }
}

sub delete_story {
    my ($self, $c ) = @_;

    no warnings 'numeric';
    my $story = $self->_story_rs
                     ->find( $c->req->param('news_story_id') + 0 )
        or $c->throw( message  => 'story not found',
                      is_error => 0 );

    $story->delete;
    $c->req->redirect( $self->_back_to($c) );
}

# strftime format string we are using on the user side.  the other
# format string (in the form conf above) is how the date is formatted
# for database insertion
sub _date_fmt {
    '%F %I:%M%p'
}

sub display_story_form {
    my ($self, $c, $form ) = @_;

    $form ||= $self->_build_story_form($c);
    $form->process;

    # fill in the form with existing values if we are updating
    no warnings 'numeric', 'uninitialized';
    if( my $story = $self->_story_rs->find( $c->req->param('news_story_id') + 0) ) {
        $form->model->default_values( $story );
        $form->default_values({
            op   => 'update',
            date => $story->date->strftime( $self->_date_fmt ),
        });
    } else {
        $form->default_values({ op => 'create' });
    }

    $c->run_mason(
        '/news/story_form.mas',
        form => $form,
       );
}

sub _story_rs {
    shift->schema->resultset('NewsStory')
}

# throws unless a user is logged in and has access to edit stories
sub check_access {
    my ($self, $c ) = @_;

    require CXGN::Login;
    require CXGN::People::Person;

    my $dbh = $c->dbc->dbh;
    my $person_id  = CXGN::Login->new($dbh)->has_session()
        or return;

    my $logged_in_person = CXGN::People::Person->new($dbh, $person_id);

    $c->throw( message => 'You must be logged in as an SGN curator to access this page', is_error => 0 )
        unless $logged_in_person && $logged_in_person->get_user_type eq 'curator';
}


1;

