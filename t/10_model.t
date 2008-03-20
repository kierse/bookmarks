#!/usr/bin/perl

use strict; use warnings;

use lib("..");
use Test::More qw/no_plan/;

use Exception qw/:try/;
use Model::User;

BEGIN 
{
	my $status = use_ok("Schema");
	BAIL_OUT("Unable to load object 'Schema', aborting")
		unless $status;
}

my $testDB = "/tmp/test.db";
my $schema;

# first things first: create a new sqlite database and all tables
unlink $testDB if -e $testDB;
ok(system("sqlite3 $testDB < ../sql/create.sql") == 0, "initializing sqlite database");

# connect to test sqlite database
ok($schema = Schema->connect("dbi:SQLite:$testDB"), "connecting to sqlite database");

# create some test users
my $user_rs = $schema->resultset("User");
my @Users = $user_rs->populate
(
	[
		{id => 0, username => 'userA', password => Model::User->encrypt_password('pass')},
		{         username => 'userB', password => Model::User->encrypt_password('pass')},
		{id => 2, username => 'userC', password => Model::User->encrypt_password('pass'), active => 0},
	],
);
ok(scalar @Users, "inserting users into database");

# insert duplicate username
Exception->flush();
try
{
	$user_rs->create({username => 'userA', password => Model::User->encrypt_password('pass')});
}
catch Exception::Server::Database with 
{
	# do nothing, test in finally block will report on error
}
finally
{
	ok(Exception::Server::Database->prior(), "attempting to insert duplicate username...");
};

# insert null username
Exception->flush();
try
{
	$user_rs->create({password => Model::User->encrypt_password('pass')});
}
catch Exception::Server::Database with 
{
	# do nothing, test in finally block will report on error
}
finally
{
	ok(Exception::Server::Database->prior(), "attempting to insert a null username...");
};

# create files for each user
my $file_rs = $schema->resultset("File");
my @Files = $file_rs->populate
(
	[
		{id => 0, name => "fileA", owner => 0, description => "userA's first file", writeable => 0, private => 1},
		{         name => "fileB", owner => 0, description => "userA's second file", writeable => 0, private => 1},
		{         name => "fileC", owner => 1, description => "userB's first file", writeable => 1, private => 0},
		{id => 3, name => "fileD", owner => 1, description => "userB's second file", writeable => 0, private => 0},
		{         name => "fileE", owner => 2, description => "userC's first file", writeable => 0, private => 0},
		{id => 5, name => "fileF", owner => 2, description => "userC's second file", writeable => 0, private => 1},
	],
);
ok(scalar @Files, "inserting files into database");

# insert duplicate file
Exception->flush();
try
{
	$file_rs->create({id => 0, name => 'fileG', owner => "userA"});
}
catch Exception::Server::Database with
{
	# do nothing, test in finally block will report on error
}
finally
{
	ok(Exception::Server::Database->prior(), "attempting to insert duplicate file...");
};

# create some folders 
my $folder_rs = $schema->resultset("Folder");
my @Folders = $folder_rs->populate
(
	[
		{id => 0, name => "folderA", lft => 1, rgt => 10, description => "this is folderA"},
		{id => 1, name => "folderB", lft => 2, rgt => 7, description => "this is folderB"},
		{id => 2, name => "folderC", lft => 3, rgt => 6, description => "this is folderC"},
		{id => 3, name => "folderD", lft => 4, rgt => 5, description => "this is folderD"},
		{id => 4, name => "folderE", lft => 8, rgt => 9, description => "this is folderE"},
	],
);
ok(scalar @Folders, "inserting folders into database");

# create bookmarks for each user
my $bookmark_rs = $schema->resultset("Bookmark");
my @Bookmarks = $bookmark_rs->populate
(
	[
		{id => 0, url => "http://digg.com", description => "social news site", folder => 0},
		{id => 1, url => "http://reddit.com", description => "social news site too", folder => 1},
		{id => 2, url => "http://slashdot.com", description => "social news site also", folder => 1}, 
	],
);
ok(scalar @Bookmarks, "inserting bookmarks into database");

# adding folders to files
my $part_of_rs = $schema->resultset("PartOf");
my @Lists = $part_of_rs->populate
(
	[
		{folder => 0, file => 0},
		{folder => 1, file => 0},
		{folder => 2, file => 0},
		{folder => 3, file => 0},
		{folder => 4, file => 0},
		{folder => 0, file => 1},
		{folder => 2, file => 1},
	],
);
ok(scalar @Lists, "adding folders to files");

# add some tags to bookmarks
my $tag_rs = $schema->resultset("Tag");
my @Tags = $tag_rs->populate
(
	[
		{tag => "social news", file => 0, bookmark => 0},
		{tag => "social news", file => 0, bookmark => 1},
		{tag => "social news", file => 0, bookmark => 2},
		{tag => "linux", file => 1, bookmark => 0},
		{tag => "technology", file => 4, bookmark => 2},
	],
);
ok(scalar @Tags, "adding tags to bookmarks");

