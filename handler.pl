#!/usr/bin/perl

use strict; use warnings;

use JSON::RPC::Server::Daemon;
use Cwd;

my $cwd = getcwd();
$ENV{"BOOKMARKS_CONFIG_PATH"} ||= "$cwd/conf";
$ENV{"BOOKMARKS_LOG_PATH"} ||= "$cwd/log";
$ENV{"BOOKMARKS_ENV"} ||= "test-harness";
$ENV{"BOOKMARKS_PORT"} ||= ($ARGV[0] || 8080);

my $server = JSON::RPC::Server::Daemon->new(LocalPort => $ENV{"BOOKMARKS_PORT"});

# set some default server and JSON encoder/decoder arguments
$server->return_die_message(1);
$server->json->allow_blessed(1);
$server->json->convert_blessed(1);

$server->dispatch({'/handler/bookmarks' => 'Controller', '/example' => 'MyApp'});

# start handler
$server->handle();
