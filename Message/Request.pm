package Message::Request;

use strict;
use warnings;

use Log::Log4perl;

use Exception::Client::Types;
use Message::Token;

use base qw/Message/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

our $AUTOLOAD;

my %Controllers = 
(
	"Bookmark" => "Handler::Bookmark",
	"File" => "Handler::File",
	"Folder" => "Handler::Folder",
	"Link" => "Handler::Link",
	"Server" => "Handler::Server",
	"Tag" => "Handler::Tag",
	"User" => "Handler::User",
);

# field declaration - - - - - - - - - - - - - - - - - - - - -

my $fields = 
{
	# method arguments
	args => [],

	# requested handler
	handler => undef,

	# handler method to invoke
	method => undef,

	# authentication token
	token => undef,

	# raw, untouched request
	_request => undef,
};

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	my ($class, $request) = @_;
	
	# create an empty request object
	my $this = $class->SUPER::new($fields);

	# generate new token object
	$this->token(Message::Token->new($request->{token}));

	# determine request handler
	throw Exception::Client::MissingRequestData("Unknown or missing handler")
		unless $Controllers{$request->{handler}} && $this->handler($Controllers{$request->{handler}});

	# set handler method to be called
	throw Exception::Client::MissingRequestData("Missing method")
		unless defined $request->{method} && $this->method($request->{method});

	# save arguments
	throw Exception::Client::MissingRequestData("Request arguments must be passed in an array")
		unless ref($request->{args}) eq "ARRAY" && $this->args($request->{args});

	# preserve original request in new object
	$this->_request($request);

	return $this;
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
