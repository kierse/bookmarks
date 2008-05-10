#!/usr/bin/perl

use strict; use warnings;

use JSON::RPC::Server::Daemon;
use Cwd;

my $cwd = getcwd();
$ENV{"BOOKMARKS_CONFIG_PATH"} = "$cwd/conf";

my $server = JSON::RPC::Server::Daemon->new(LocalPort => $ARGV[0]);

# set some default server and JSON encoder/decoder arguments
$server->return_die_message(1);
$server->json->allow_blessed(1);
$server->json->convert_blessed(1);

$server->dispatch({'/bookmarks' => 'Controller'});

# start handler
$server->handle();
