package Handler;

use strict;
use warnings;

use Exception;
use Exception::Server::Types;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub add
{
	my ($class, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs($request->handler() . "->add expects one or more arguments")
		unless scalar @$args;
	
	throw Exception::Client::InvalidRequestData($request->handler() . "->add expects arguments of type object")
		if grep { ref $_ ne "HASH" } @$args;
}

sub update
{
	my ($class, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs($request->handler() . "->update expects one or more arguments")
		unless scalar @$args;
	
	throw Exception::Client::InvalidRequestData($request->handler() . "->update expects arguments of type object")
		unless grep { ref $_ eq "HASH" } @$args;
}

sub delete
{
	my ($class, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs($request->handler() . "->delete expects one or more argument")
		unless scalar @$args;
	
	throw Exception::Client::InvalidRequestData($request->handler() . "->delete expects arguments of type object")
		unless grep { ref $_ eq "HASH" } @$args;
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
