package Controller;

use strict;
use warnings;

use Config::General;
use Error qw/:try/;

use base qw/JSON::RPC::Procedure/;

use Exception::Server::Types;
use Logger;
use Message::Request;
use Message::Response;
use Schema;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

my $config_path = "BOOKMARKS_CONFIG_PATH";

our %CONFIGS;

our $SCHEMA;

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

   	# deserialize the client message and construct a request object
		my $request = Message::Request->new($request);

   	# invoke the appropriate controller and hand off processing 
   	# the request to it
   	require UNIVERSAL::require;

   	my $handler = $request->handler();
   	my $method = $request->method();

		throw Exception::Server::UNIVERSALRequireFailure($@)
			unless $handler->require();

		throw Exception::Server::UnknownMethod("Unknown method '$method' in handler '$handler'.")
			unless $handler->can($method);

   	$SCHEMA->txn_do(sub { $handler->$method($request, $response) });
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

# private methods - - - - - - - - - - - - - - - - - - - - - -

sub _init : Private
{
	throw Exception::Server::InvalidConfiguration("Undefined environment variable: BOOKMARKS_CONFIG_PATH")
		unless $ENV{$config_path};

	throw Exception::Server::FileNotFound("Missing config file at ". $ENV{$config_path} . "/log4perl.conf")
		unless -e $ENV{$config_path} . "/log4perl.conf";

	# initialize logger
	Logger->init($ENV{$config_path} . "/log4perl.conf");
	my $logger = Logger->get_logger();
	
	# read in server config file
	unless (defined %CONFIGS)
	{
		throw Exception::Server::FileNotFound("Missing config file at ". $ENV{$config_path} . "/application.conf")
			unless -e $ENV{$config_path} . "/application.conf";

		%CONFIGS = Config::General->new
		(
			'-ConfigPath' => $ENV{$config_path},
			'-ConfigFile' => "application.conf",
		)->getall();
	}

	# connect to database
	$SCHEMA = Schema->connect($CONFIGS{"db_connect_string"})
		unless defined $SCHEMA;

	# check if sql debug flag is 1.  If yes, turn on debugging!
	if ($CONFIGS{'sql_debug'})
	{
		#my $ql = DBIx::Class::QueryLog->new();
		#$SCHEMA->storage->debugobj($ql);
		$SCHEMA->storage->debug(1);
	}
}

1;
