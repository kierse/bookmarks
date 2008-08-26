#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use JSON::RPC::Client;
use Data::Dumper;
use lib("..");

# fork process and start server in child process
if (my $pid = fork)
{
	#-#-# parent process #-#-#
	
	# sleep for a few seconds to give the server time to start
	sleep 2;

	my $url = "http://localhost:$ENV{BOOKMARKS_PORT}/bookmarks";

	my $client = JSON::RPC::Client->new();
	my $callObj =
	{
		method => "request",
		params => 
		[
			{
				args => [],
				handler => "Server",
				method => "version",
				token => { username => 'userA', password => 'pass' },
			},
		],
	};

	my $response = $client->call($url, $callObj);

	if ($response)
	{
		my $dumper = Data::Dumper->new([$response->content()]);
		$dumper->Terse(1);

		print $dumper->Dump();
	}

	# kill server
	system("kill -9 $pid");
}
elsif (defined $pid)
{
	#-#-# child process #-#-#
	chdir "..";
	exec "perl", "handler.pl", $ENV{'BOOKMARKS_PORT'};
}
else
{
	#-#-# fork error #-#-#
}


