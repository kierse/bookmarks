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

# CREATE new file
my $request =
{
	token => { username => 'userA', password => 'pass' },
	handler => 'File',
	method => 'add',
	args =>
	[
		{
			name => "fileG", 
			owner => 0,
			description => "Test fileG",
		},
	],
};

my $response = Controller->request($request);
my $model = Controller->get_model();

SKIP:
{
	skip "create failed, further checks unnecessary"
		unless ok($response->status() eq 1, "CREATE new file");

	my $rawFile = $request->{args}[0];
	my $file = $model->resultset('File')->find
	(
		{
			name => $rawFile->{name}, 
			owner => $rawFile->{owner}
		}, 
		{ key => 'file_name_owner' },
	);

	ok($rawFile->{name} eq $file->name(), "verify new file name");
};

diag $response->error()->stringify() if $response->status eq -1;

# UPDATE existing file
$request = 
{
	token => { id => 0, username => 'userA', password => 'pass' },
	handler => 'File',
	method => 'update',
	args =>
	[
		{
			name => "fileG", 
		},
		{
			description => "Test fileG is now a public file!",
		},
	],
};

$response = Controller->request($request);

SKIP:
{
	skip "update failed, further checks unnecessary"
		unless ok($response->status() eq 1, "UPDATE existing file");

	my $file = $model->resultset('File')->find
	(
		{
			name => $request->{args}[0]{name}, 
			owner => $request->{token}{id},
		}, 
		{key=>'file_name_owner'}
	);

	is($file->description(), "Test fileG is now a public file!", "verify updated file description");
};

diag $response->error()->stringify() if $response->status eq -1;

# DELETE existing file
$request = 
{
	token => { id => 0, username => 'userA', password => 'pass' },
	handler => 'File',
	method => 'delete',
	args =>
	[
		{
			name => "fileG", 
		},
	],
};

$response = Controller->request($request);

SKIP:
{
	skip "delete failed, further checks unnecessary"
		unless ok($response->status() eq 1, "DELETE existing file");

	my $file = $model->resultset('File')->find
	(
		{
			name => $request->{args}[0]{name}, 
			owner => $request->{token}{id},
		},
		{key=>'file_name_owner'}
	);

	is($file, undef, "verify existing file deleted");
};

diag $response->error()->stringify() if $response->status eq -1;

