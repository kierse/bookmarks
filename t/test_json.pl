#!/usr/bin/perl

use strict;
use warnings;

use JSON::RPC::Client;
use Data::Dumper;

my $url = "http://localhost:" . $ARGV[0] . "/bookmarks";

my $client = JSON::RPC::Client->new();

#$client->prepare($url, ["request"]);
#my $response = $client->request({"handler" => "Server", "method" => "version"});

#if ($response->is_success())
#{
#	print $response->content();
#}
#else
#{
#	print $response->content();
#};

#OO usage
#$d = Data::Dumper->new([$foo, $bar], [qw(foo *ary)]);
#...
#print $d->Dump;
#...
#$d->Purity(1)->Terse(1)->Deepcopy(1);
#eval $d->Dump;

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

#if ($response)
#{
#	if ($response->is_error)
#	{
#		print $dumper->Dump();
#	}
#	else
#	{
#		print $response->result;
#	}
#}
#else
#{
#	print $dumper->Dump();
#}

