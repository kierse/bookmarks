package Handler::User;

use strict;
use warnings;

use Controller;
use Exception::Server::Types;
use Logger;

use base qw/Handler/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub add
{
	my $class = shift;
	my ($request, $response) = @_;

	$class->SUPER::add(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my $args = $request->args();

	# create new user using request data
	my $user = $model->resultset('User')->create($args->[0]);

	return unless ref $user;

	# made it this far, set status to 1 on response
	$response->status(1);
}

sub update
{
	my $class = shift;
	my ($request, $response) = @_;
	my $user = $request->token()->user();

	$class->SUPER::update(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my $args = $request->args();

	throw Exception::Client::MissingRequestData(__PACKAGE__ . "::update requires a valid username or id")
		unless defined $args->[0]{"id"} || defined $args->[0]{"username"};
	
	throw Exception::Client::IllegalRequest("Unable to perform update.  Requesting user and update data does not match")
		unless ($args->[0]{"id"} && $args->[0]{"id"} eq $user->id()) || 
			($args->[0]{"username"} && $args->[0]{"username"} eq $user->username());

	# sanitize given data to ensure caller isn't trying to update
	# any locked fields
	delete $args->[1]{"id"};
	delete $args->[1]{"username"};

	# attempt to update user object using given data
	# set status on response object with results of update
	$user->update($args->[1]);
	$response->status(1);
}

sub delete
{
	my $class = shift;
	my ($request, $response) = @_;

	$class->SUPER::delete(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my $args = $request->args();
	my $user = $request->token()->user();

	throw Exception::Client::MissingRequestData(__PACKAGE__ . "::delete requires a valid username or id")
		unless defined $args->[0]{"id"} || defined $args->[0]{"username"};

	throw Exception::Client::IllegalRequest("Unable to delete user.  Requesting user and delete data does not match")
		unless ($args->[0]{"id"} && $args->[0]{"id"} eq $user->id()) || 
			($args->[0]{"username"} && $args->[0]{"username"} eq $user->username());

	$user->delete();

	# set the response status to 1 unless the user 
	# object wasn't deleted
	$response->status(1) unless $user->in_storage();
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
