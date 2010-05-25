use strict;
use warnings;

use SGN::Controller::News;

##  this CGI is just a dispatcher for the CRUD operations, see the
##  controller class for the real action

my $self = SGN::Controller::News->new;

# access control, throws with access message if no access
$self->check_access($c);

my $op = $c->req->param('op')
    || ( $c->req->param('news_story_id') ? 'update' : 'create' );

my %dispatch = (
    create  => 'create_story',
    update  => 'update_story',
    delete  => 'delete_story',
);

my $opname = $dispatch{ $op }
    or $c->throw( message => 'invalid request', is_error => 0 );

$self->$opname($c);

exit;
