package SGN::Controller::News;
use Moose;
use namespace::autoclean;

use Carp qw/ confess /;

use HTML::FormFu;

use CXGN::Login;
use CXGN::People::Person;

use SGN::News::Schema;

use YAML ();

# the HTML::FormFu form that we use for editing news stories
sub _build_story_form {
    my ($self,$c) = @_;
    $c or confess 'must pass c';

    my $form = HTML::FormFu->new(YAML::Load(<<'EOY'));
      method: POST
      model_config:
         resultset: NewsStory
      elements:
          - type: Date
            name: date
            label: Date
            default_natural: today

          - type: Hidden
            name: news_story_id

          - type: Text
            name: headline
            label: Headline
            size: 60

          - type: Textarea
            cols: 50
            rows: 5
            label: Body
            name: body

          - type: Submit
            name: submit
EOY

    $form->stash->{schema} = $c->dbic_schema('SGN::News::Schema');
    $form->process( $c->req );

    return $form;
}

sub create_story {
    my ($self, $c ) = @_;

    my $form = $self->_build_story_form($c);

    if( $form->submitted_and_valid ) {
        my $story = $form->model->create;
        $c->req->redirect('');
    } else {
        $c->throw( message  => 'invalid story submission',
                   is_error => 0,
                   developer_message => do { require Data::Dumper; '<pre>'.Data::Dumper::Dumper( $form->get_errors ).'< },
                  );
    }
}

sub update_story {
    my ($self, $c ) = @_;

    my $form = $self->_build_story_form($c);

    $form->model->update
        if $form->submitted_and_valid;

    $c->req->redirect( $c->req->url( -query => 1 ));
}

sub delete_story {
    my ($self, $c ) = @_;

    my $story = $self->_story_rs($c)
                     ->find( $c->req->param('news_story_id') )
        or $c->throw( message  => 'story not found',
                      is_error => 0 );

    $story->delete;
}

sub display_story_form {
    my ($self, $c ) = @_;

    my $form = $self->_build_story_form($c);

    if( my $id = $c->req->param('news_story_id') ) {
        if( my $story = $self->_story_rs($c)->find( $id ) ) {
            $form->model->default_values( $story )
        }
    }

    $c->forward_to_mason_view(
        '/news/story_form.mas',
        form => $form,
       );
}

sub _story_rs {
    my ($self,$c) = @_;
    $c->dbic_schema('SGN::News::Schema')
      ->resultset('NewsStory')
}

# throws unless a user is logged in and has access to edit stories
sub check_access {
    my ($self, $c ) = @_;

    my $dbh = $c->dbc->dbh;
    my $person_id  = CXGN::Login->new($dbh)->has_session()
        or return;

    my $logged_in_person = CXGN::People::Person->new($dbh, $person_id);

    $c->throw( message => 'You must be logged in as an SGN curator to access this page', is_error => 0 )
        unless $logged_in_person && $logged_in_person->get_user_type eq 'curator';
}


1;

