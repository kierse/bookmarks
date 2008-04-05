#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use FindBin qw/$Bin/;
use lib("..");

use Controller;

# set some needed environment variables
$ENV{"BOOKMARKS_CONFIG_PATH"} = "$Bin/../conf";

BEGIN 
{
	my $status = use_ok("Controller");
	BAIL_OUT("Unable to load object 'Controller', aborting")
		unless $status;
}

# import a new bookmark hierarchy method #1
my $request = 
{
	token => { username => 'userA', password => 'pass' },
	handler => 'Bookmark',
	method => 'buildHierarchy',
	args => 
	[
		{title => "1a", lft => 0, rgt => 25, level => 0, file => 0},
		{title => "1b", lft => 1, rgt => 10, level => 1, file => 0},
		{title => "1c", lft => 11, rgt => 24, level => 1, file => 0},
		{title => "1d", lft => 2, rgt => 3, level => 2, file => 0},
		{title => "1e", lft => 4, rgt => 9, level => 2, file => 0},
		{title => "1f", lft => 12, rgt => 13, level => 2, file => 0},
		{title => "1g", lft => 14, rgt => 23, level => 2, file => 0},
		{title => "1h", lft => 5, rgt => 6, level => 3, file => 0},
		{title => "1i", lft => 7, rgt => 8, level => 3, file => 0},
		{title => "1j", lft => 15, rgt => 22, level => 3, file => 0},
		{title => "1k", lft => 16, rgt => 17, level => 4, file => 0},
		{title => "1l", lft => 18, rgt => 19, level => 4, file => 0},
		{title => "1m", lft => 20, rgt => 21, level => 4, file => 0},
	],
};
my $size = scalar @{$request->{args}};
my $rgt = $request->{args}[0]{rgt};

my $response = Controller->request($request);
my $model = Controller->get_model();

SKIP:
{
	skip "import failed, further checks unnecessary"
		unless ok($response->status eq 1, "IMPORT new hierarchy method #1");

	my @Files = $model->resultset('Bookmark')->search({file => $request->{args}[0]{file}});

	is(scalar @Files, $size, "verify correct number of bookmarks were inserted");
	is($Files[0]->title(), $request->{args}[0]->{title}, "checking beginning of hierarchy");
	is($Files[$#Files]->title(), $request->{args}[$size-1]->{title}, "checking end of hierarchy");
}
diag $response->error()->stringify() if $response->status eq -1;

# import a new bookmark hierarchy method #2
$request = 
{
	token => { username => 'userA', password => 'pass' },
	handler => 'Bookmark',
	method => 'buildHierarchy',
	args => 
	[
		{
			title => "2a", 
			file => 1,
			_children => 
			[
				{
					title => "2b", 
					file => 1,
					_children =>
					[
						{title => "2d", file => 1},
						{
							title => "2e", 
							file => 1,
							_children =>
							[
								{title => "2h", file => 1},
								{title => "2i", file => 1},
							],
						},
					],
				},
				{
					title => "2c", 
					file => 1,
					_children =>
					[
						{title => "2f", file => 1},
						{
							title => "2g", 
							file => 1,
							_children =>
							[
								{
									title => "2j", 
									file => 1,
									_children => 
									[
										{title => "2k", file => 1},
										{title => "2l", file => 1},
										{title => "2m", file => 1},
									],
								},
							],
						},
					],
				},
			],
		},
	],
};

$response = Controller->request($request);

SKIP:
{
	skip "import failed, further checks unnecessary"
		unless ok($response->status eq 1, "IMPORT new hierarchy method #2");

	my @Files = $model->resultset('Bookmark')->search({file => $request->{args}[0]{file}});

	is(scalar @Files, $size, "verify correct number of bookmarks were inserted");
	is($Files[0]->title(), $request->{args}[0]->{title}, "checking beginning of hierarchy");
	is($Files[$#Files]->title(), "2m", "checking end of hierarchy");
}
diag $response->error()->stringify() if $response->status eq -1;

# INSERT a few new bookmarks method #1
$request =
{
	token => { username => 'userA', password => 'pass' },
	handler => 'Bookmark',
	method => 'add',
	args => 
	[
		{title => "1n", lft => 3, rgt => 4, level => 3, file => 0},
		{title => "1o", lft => 14, rgt => 15, level => 2, file => 0},
		{title => "1p", lft => 25, rgt => 26, level => 5, file => 0},
	],
};
$size += scalar @{$request->{args}};
$rgt += 2 * scalar @{$request->{args}};

$response = Controller->request($request);

SKIP:
{
	skip "insert failed, further checks unnecessary"
		unless ok($response->status() eq 1, "INSERT new bookmarks method #1");

	my @Files = $model->resultset('Bookmark')->search({file => $request->{args}[0]{file}});
	is(scalar @Files, $size, "verify correct number of bookmarks were inserted");
	is($Files[0]->rgt(), $rgt, "verify that hierarchy root was correctly updated");
	is($Files[$#Files]->title(), "1p", "checking end of hierarchy");
};
diag $response->error()->stringify() if $response->status eq -1;

# grab some helper data...
SKIP:
{
	my @Parents = $model->resultset('Bookmark')->search({title => {-in => ['2d','2c','2m']}});
	skip "failed to retrieve parent bookmarks, further checks unnecessary"
		unless scalar @Parents eq 3;

	$request =
	{
		token => { username => 'userA', password => 'pass' },
		handler => 'Bookmark',
		method => 'add',
		args => 
		[
			{title => "2n", file => 1, _parent => $Parents[0]->id(), _position => 0},
			{title => "2o", file => 1, _parent => $Parents[1]->id(), _position => 0},
			{title => "2p", file => 1, _parent => $Parents[2]->id(), _position => 0},
		],
	};
	$size += scalar @{$request->args};
	$rgt += 2 * scalar @{$request->args};

	$response = Controller->request($request);

	SKIP:
	{
		skip "insert failed, further checks unnecessary"
			unless ok($response->status() eq 1, "INSERT new bookmarks method #2");

		my @Files = $model->resultset('Bookmark')->search({file => $request->{args}[0]{file}});
		is(scalar @Files, $size, "verify correct number of bookmarks were inserted");
		is($Files[0]->rgt(), $rgt, "verify that hierarchy root was correctly updated");
		is($Files[$#Files]->title(), "2p", "checking end of hierarchy");
	};
	diag $response->error()->stringify() if $response->status eq -1;
};

