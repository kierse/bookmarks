package Controller;

use strict;
use warnings;

use Config::General;
use Error qw/:try/;
use Log::Log4perl;

use base qw/JSON::RPC::Procedure/;

use Exception::Server::Types;
use Message::Request;
use Message::Response;
use Schema;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

our %CONFIGS;

our $SCHEMA;

our $LOGGER;

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub request : Obj()
{
	my ($class, $request) = @_;
	my $response;

   try
   {
   	# first things first, initialize the controller
   	_init();

   	# create a new empty response object
   	$response = Message::Response->new();

   	# deserialize the client request and construct a Request object
   	$request = Message::Request->new($request);

   	# invoke the appropriate controller and hand off processing 
   	# the request to it
   	require UNIVERSAL::require;

   	my $handler = $request->handler();
   	my $method = $request->method();

		throw Exception::Server::UNIVERSALRequireFailure($@)
			unless $handler->require();

		throw Exception::Server::UnknownMethod("Unknown method '$method' in handler '$handler'.")
			unless $handler->can($method);

   	$handler->$method($request, $response);
   }
   catch Exception with
   {
		my $e = shift;

   	# if we've got a valid response object
   	# add the error to the response object, set
   	# the request status, and continue
   	if (ref $response)
   	{
   		# add error to response
   		$response->error($e);

   		# make sure the response does not contain any valid data
   		# and the status is set to -1
   		$response->response([]);
   		$response->status(-1);
   	}

		# we don't have a response object, something sinister happened
		# manually create a minimal response for the client and continue
   	else
   	{
			$response = 
			{
				status => -1,
				error => $e,
			};
   	}
   };

	return $response;
}

sub get_model : Private { return $SCHEMA; }

sub get_configs : Private { return %CONFIGS; }

sub get_logger : Private { return $LOGGER; }

# private methods - - - - - - - - - - - - - - - - - - - - - -

sub _init : Private
{
	# initialize logger
	$LOGGER = Log::Log4perl->init_once($ENV{'BOOKMARKS_CONFIG_PATH'} . "/logging.conf");
	
	# read in server config file
	unless (defined %CONFIGS)
	{
		%CONFIGS = Config::General->new
		(
			'-ConfigPath' => $ENV{'BOOKMARKS_CONFIG_PATH'},
			'-ConfigFile' => "bookmarks.conf",
		)->getall();
	}

	# connect to database
	$SCHEMA = Schema->connect($CONFIGS{"db_connect_string"})
		unless defined $SCHEMA;
}

1;
