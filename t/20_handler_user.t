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

# CREATE new User
my $tID = 5;
my $request = 
{
	token => { username => 'userA', password => 'pass' },
	handler => 'User',
	method => 'add',
	args => 
	[
		{
			_tID => $tID,
			username => "testUser",
			password => "testPass",
			name => "Test User",
			email => 'test@example.com',
		},
	],
};

my $response = Controller->request($request);
my $model = Controller->get_model();

SKIP:
{
	skip "create failed, further checks unnecessary"
		unless ok($response->status() eq 1, "CREATE new user");

	my $rawUser = $request->{args}[0];
	my $id = $response->args()->[0]{$tID};
	my $user = $model->resultset('User')->find($id);

	ok($rawUser->{name} eq $user->name(), "verify new user name");
	ok($rawUser->{email} eq $user->email(), "verify new user email");
};

diag $response->error()->stringify() if $response->status eq -1;

# UPDATE existing user
$request =
{
	token => { username => 'testUser', password => 'testPass' },
	handler => 'User',
	method => 'update',
	args => 
	[
		{
			username => "testUser",
		},
		{
			username => "testUser",
			password => "newTestPass",
			name => "New Test User",
			email => 'test2@example.com',
		},
	],
};
$response = Controller->request($request);

SKIP:
{
	skip "update failed, further checks unnecessary"
		unless ok($response->status() eq 1, "UPDATE existing user");

	my $rawUser = $request->{args}[0];
	my $user = $model->resultset('User')->find($request->{args}[0]{username}, {key=>'user_username'});
	ok($request->{args}[1]{name} eq $user->name(), "verifying updated user name");
	ok($request->{args}[1]{email} eq $user->email(), "verifying updated user email");
};

diag $response->error()->stringify() if $response->status eq -1;

# DELETE existing user
$request = 
{
	token => { username => 'testUser', password => 'newTestPass' },
	handler => 'User',
	method => 'delete',
	args => 
	[
		{
			username => "testUser",
		},
	],
};
$response = Controller->request($request);

SKIP:
{
	skip "deletion failed, further checks unnecessary"
		unless ok($response->status() eq 1, "DELETE existing user");

	is($model->resultset('User')->find($request->{args}[0]{username}, {key=>'user_username'}), undef, "verifying user was deleted");
}

diag $response->error()->stringify() if $response->status eq -1;

