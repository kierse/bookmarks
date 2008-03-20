#!/usr/bin/perl

use JSON::RPC::Server::CGI;
use Controller;

# create a new instance of the JSON::RPC CGI server
my $server = JSON::RPC::Server::CGI->new();

# create request handler and declare all url mappings
$server->dispatch({'/bookmarks' => 'Controller'});

# start handler
$server->handle();
