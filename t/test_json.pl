#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use JSON::RPC::Client;
use Data::Dumper;

#my $url = "http://localhost:" . $ARGV[0] . "/bookmarks";
my $url = "http://localhost:" . $ARGV[0] . "/handler/bookmarks";

my $client = JSON::RPC::Client->new();

#$client->prepare($url, ["request"]);
#my $response = $client->request({ args => [], handler => "Server", method => "version", token => { username => 'userA', password => 'pass' }, });
#
#if ($response->is_success())
#{
#	print $response->content();
#}
#else
#{
#	print $response->content();
#};
#
my $callObj =
{
	method => "request",
	version => "1.1",
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

#my $response = $client->call($url, $callObj);
#
#if ($response)
#{
#	my $dumper = Data::Dumper->new([$response->content()]);
#	$dumper->Terse(1);
#
#	print $dumper->Dump();
#}

my $encoded = to_json($callObj);
my $request = HTTP::Request->new(POST => $url);
$request->header("Content-Type" => "application/json");
$request->content($encoded);

print $request->as_string;

my $ua = LWP::UserAgent->new();
my $response = $ua->request($request);

print $response->as_string;
