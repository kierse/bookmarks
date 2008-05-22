#!/usr/bin/perl

use strict; use warnings;

use JSON::RPC::Server::CGI;
use Cwd;

my $cwd = getcwd();
$ENV{"BOOKMARKS_CONFIG_PATH"} ||= "$cwd/conf";
$ENV{"BOOKMARKS_LOG_PATH"} ||= "$cwd/log";
$ENV{"BOOKMARKS_ENV"} ||= "test-harness";

# create a new instance of the JSON::RPC CGI server
my $server = JSON::RPC::Server::CGI->new();

# set some default server and JSON encoder/decoder arguments
$server->return_die_message(1);
$server->json->allow_blessed(1);
$server->json->convert_blessed(1);

# create request handler and declare all url mappings
$server->dispatch({'/bookmarks' => 'Controller'});

# start handler
$server->handle();

