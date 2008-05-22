package Handler;

use strict;
use warnings;

use Exception;
use Exception::Server::Types;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub add
{
	my ($server, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs($request->handler() . "->add expects one or more arguments")
		unless scalar @$args;
	
	throw Exception::Client::InvalidRequestData($request->handler() . "->add expects arguments of type object")
		if grep { ref $_ ne "HASH" } @$args;
}

sub update
{
	my ($server, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs($request->handler() . "->update expects one or more arguments")
		unless scalar @$args;
	
	throw Exception::Client::InvalidRequestData($request->handler() . "->update expects arguments of type object")
		unless grep { ref $_ eq "HASH" } @$args;
}

sub delete
{
	my ($server, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs($request->handler() . "->delete expects one or more argument")
		unless scalar @$args;
	
	throw Exception::Client::InvalidRequestData($request->handler() . "->delete expects arguments of type object")
		unless grep { ref $_ eq "HASH" } @$args;
}

sub _get_temporary_id
{
	my ($server, $request, $raw) = @_;

	throw Exception::Client::InvalidRequest("All arguments passed to " . $request->handler() . "->" . $request->method() . " must have a temporary id (_tID)")
		unless exists $raw->{_tID};

	return delete $raw->{_tID};
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
