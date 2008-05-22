#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use lib("..");

use Controller;

BEGIN 
{
	my $status = use_ok("Controller");
	BAIL_OUT("Unable to load object 'Controller', aborting")
		unless $status;
}

# CREATE new bookmarks
my $request = 
{
	token => { username => 'userA', password => 'pass' },
	handler => 'Bookmark',
	method => 'add',
	args =>
	[
		{
			url => "http://1.example.com",
			title => "example 1",
			folder => 2,
			description => "example bookmark #1",
		},
		{
			url => "http://2.example.com",
			title => "example 2",
			folder => 2,
			description => "example bookmark #2",
		},
		{
			url => "http://3.example.com",
			title => "example 3",
			folder => 2,
			description => "example bookmark #3",
		},
		{
			url => "http://4.example.com",
			title => "example 4",
			folder => 3,
			description => "example bookmark #4",
		},
		{
			url => "http://5.example.com",
			title => "example 5",
			folder => 3,
			description => "example bookmark #5",
		},
	],
};

my $response = Controller->request($request);
my $model = Controller->get_model();

SKIP:
{
	skip "create failed, further checks unnecessary"
		unless ok($response->status eq 1, "CREATE new bookmark(s)");

	my @Bookmarks = $model->resultset('Bookmark')->search([{folder => 2},{folder=>3}], {order_by => ["folder","id"]});
	is(scalar @Bookmarks, 5, "verifying insertion count");
	is($Bookmarks[0]->url(), "http://1.example.com", "verifying bookmark url");
	is($Bookmarks[2]->title(), "example 3", "verifying bookmark title");
	is($Bookmarks[4]->description(), "example bookmark #5", "verifying bookmark description");
	is($Bookmarks[3]->folder()->id(), 3, "verifying bookmark folder id");
};

# UPDATE existing bookmark
$request = 
{
	token => { username => 'userA', password => 'pass' },
	handler => 'Bookmark',
	method => 'update',
	args =>
	[
		{

		},
	],
};

