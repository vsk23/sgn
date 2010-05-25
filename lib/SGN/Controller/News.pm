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

    my $date_fmt = $self->_date_fmt;
    my $form = HTML::FormFu->new(YAML::Load(<<EOY));
      method: POST
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

          - type: Hidden
            name: op

          - type: Hidden
            name: backto

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

#    $form->element({ type => 'Hidden', name => 'operation', default => $self->_backto($c) });

    # embed a back-to url in the form, and the default date of right now (server time)
    $form->default_values({
        backto => $self->_backto($c),
        date   => lc DateTime->now( time_zone => 'local' )->strftime( $date_fmt ),
       });

    $form->stash->{schema} = $c->dbic_schema('SGN::News::Schema');

    return $form;
}
sub _backto {
    my ($self, $c) = @_;
    my $back_to_url = $c->req->param('backto') || $c->req->url( -relative => 1 );
    $back_to_url =~ s|://||; #< foil any cross-site redirecting
    return $back_to_url;
}

sub create_update_story {
    my ($self, $c ) = @_;

    my $form = $self->_build_story_form($c);
    $form->process( $c->req );

    if( $form->submitted_and_valid ) {
        if( my $story = $self->_story_rs($c)->find( $form->param_value('news_story_id') + 0)) {
            $form->model->update( $story );
        } else {
            $form->model->create;
        }
        $c->req->redirect( $self->_backto($c) );
    } else {
        $self->display_story_form($c,$form);
    }
}

sub delete_story {
    my ($self, $c ) = @_;

    my $story = $self->_story_rs($c)
                     ->find( $c->req->param('news_story_id') )
        or $c->throw( message  => 'story not found',
                      is_error => 0 );

    $story->delete;
}

sub _date_fmt {
    '%F %I:%M%p'
}

sub display_story_form {
    my ($self, $c, $form ) = @_;

    $form ||= $self->_build_story_form($c);

    # embed in the form an 'op' field that tells whether we are creating or updating
    no warnings 'numeric';
    if( my $story = $self->_story_rs($c)->find( $c->req->param('news_story_id') + 0) ) {
        $form->model->default_values( $story );
        $form->default_values({ op => 'update',
                                date => $story->date->strftime( $self->_date_fmt ),
                            });
    } else {
        $form->default_values({ op => 'create' });
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

