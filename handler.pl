#!/usr/bin/perl

use strict; use warnings;

use JSON::RPC::Server::Daemon;

my $server = JSON::RPC::Server::Daemon->new(LocalPort => 8080);

$server->dispatch({'/bookmarks' => 'Controller'});

# start handler
$server->handle();
