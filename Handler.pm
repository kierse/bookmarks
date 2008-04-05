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

	throw Exception::Client::WrongNumberOfArgs(__PACKAGE__ . "::update expects two and only two arguments")
		unless scalar @$args eq 2;
	
	throw Exception::Client::InvalidRequestData(__PACKAGE__ . "::update expects all arguments to be objects")
		unless grep { ref $_ eq "HASH" } @$args;
}

sub delete
{
	my ($class, $request, $response) = @_;
	my $args = $request->args();

	throw Exception::Client::WrongNumberOfArgs(__PACKAGE__ . "::delete expects one and only one argument")
		unless scalar @$args eq 1;
	
	throw Exception::Client::InvalidRequestData(__PACKAGE__ . "::delete expects an object argument")
		unless ref $args->[0] eq "HASH";
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
