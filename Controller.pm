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
my $log_path = "BOOKMARKS_LOG_PATH";

our %CONFIGS;

our $SCHEMA;

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub request : Obj(request)
{
	my ($JSONServer, $obj) = @_;
	my ($request, $response);

#  try
#  {
   	# first things first, initialize the controller
   	_init();

   	# create a new empty response object
   	$response = Message::Response->new();

   	# deserialize the client message and construct a request object
		$request = Message::Request->new($obj->{request});

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
#  }
#  catch Exception with
#  {
#  	my ($e, $continue) = @_;

#  	# if we've got a valid response object
#  	# add the error to the response object, set
#  	# the request status, and continue
#  	if (ref $response)
#  	{
#  		# add error to response
#  		$response->error($e);

#  		# make sure the response does not contain any valid data
#  		# and the status is set to -1
#  		$response->args([]);
#  		$response->status(-1);
#  	}

#  	# we don't have a response object, something sinister happened
#  	# manually create a minimal response for the client and continue
#  	else
#  	{
#  		$response = 
#  		{
#  			status => -1,
#  			error => $e,
#  		};
#  	}

#  	$$continue = 1;
#  };

	# clear all recorded but unreported errors...
	Error->flush();

	return $response;
}

sub get_model : Private { return $SCHEMA; }

sub get_configs : Private { return %CONFIGS; }

# private methods - - - - - - - - - - - - - - - - - - - - - -

sub _init : Private
{
	throw Exception::Server::InvalidConfiguration("Undefined environment variable: $config_path")
		unless $ENV{$config_path};

	throw Exception::Server::InvalidConfiguration("Undefined environment variable: $log_path")
		unless $ENV{$log_path};

	throw Exception::Server::FileNotFound("Missing config file at ". $ENV{$config_path} . "/log4perl.conf")
		unless -e ($ENV{$config_path} . "/log4perl.conf");

	# initialize logger
	Logger->init($ENV{$config_path} . "/log4perl.conf");
	my $logger = Logger->get_logger();
	
	# read in server config file
	unless (defined %CONFIGS)
	{
		throw Exception::Server::FileNotFound("Missing config file at ". $ENV{$config_path} . "/application.conf")
			unless -e ($ENV{$config_path} . "/application.conf");

		%CONFIGS = Config::General->new
		(
			'-ConfigPath' => $ENV{$config_path},
			'-ConfigFile' => "application.conf",
		)->getall();
	}

	# ensure that an environment is specified
	# either as an environment variable or in the application config file
	my $env = $ENV{"BOOKMARKS_ENV"}
		? $ENV{"BOOKMARKS_ENV"}
		: $CONFIGS{"default"};

	throw Exception::Server::InvalidConfiguration("Undefined environment variable: ENV")
		unless $env;

	my $environment = $CONFIGS{"env"}{$env};
	throw Exception::Server::InvalidConfiguration("Specified environment ($env) does not exist in $ENV{$config_path}/application.conf")
		unless ref $environment eq "HASH";

	# connect to database
	$SCHEMA = Schema->connect
	(
		$environment->{"db_connect_string"}, 
		$environment->{"db_username"}, 
		$environment->{"db_password"}, 
		$environment->{"db_params"}
	) unless defined $SCHEMA;

	# check if sql debug flag is 1.  If yes, turn on debugging!
	if ($CONFIGS{'sql_debug'})
	{
		#my $ql = DBIx::Class::QueryLog->new();
		#$SCHEMA->storage->debugobj($ql);
		$SCHEMA->storage->debug(1);
	}
}

1;
