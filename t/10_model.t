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
	ok(Exception::Server::Database->prior(), "attempting to insert duplicate username");
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
	ok(Exception::Server::Database->prior(), "attempting to insert a null username");
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

# create a bookmarks hierarchy structure
my $bookmark_rs = $schema->resultset("Bookmark");
my @Bookmarks = $bookmark_rs->populate
(
	[
		{id => 0, title => "A", lft => 0, rgt => 25, level => 0, file => 5},
		{id => 1, title => "B", lft => 1, rgt => 10, level => 1, file => 5},
		{id => 2, title => "C", lft => 11, rgt => 24, level => 1, file => 5},
		{id => 3, title => "D", lft => 2, rgt => 3, level => 2, file => 5},
		{id => 4, title => "E", lft => 4, rgt => 9, level => 2, file => 5},
		{id => 5, title => "F", lft => 12, rgt => 13, level => 2, file => 5},
		{id => 6, title => "G", lft => 14, rgt => 23, level => 2, file => 5},
		{id => 7, title => "H", lft => 5, rgt => 6, level => 3, file => 5},
		{id => 8, title => "I", lft => 7, rgt => 8, level => 3, file => 5},
		{id => 9, title => "J", lft => 15, rgt => 22, level => 3, file => 5},
		{id => 10, title => "K", lft => 16, rgt => 17, level => 4, file => 5},
		{id => 11, title => "L", lft => 18, rgt => 19, level => 4, file => 5},
		{id => 12, title => "M", lft => 20, rgt => 21, level => 4, file => 5},
	],
);
ok(scalar @Bookmarks, "inserting bookmarks into database");

# attempt to insert non-unique bookmark
Exception->flush();
try
{
	$bookmark_rs->create({id => 13, title => "invalid", lft => 0, rgt => 25, level => 0, file => 5});
}
catch Exception::Server::Database with
{
	# do nothing, test in finally block will report on error
}
finally
{
	ok(Exception::Server::Database->prior(), "attempting to insert non-unique bookmark");
};

# create some folders 
my $folder_rs = $schema->resultset("Folder");
my @Folders = $folder_rs->populate
(
	[
		{id => 0, bookmark => 0, description => "this is folderA"},
		{id => 1, bookmark => 1, description => "this is folderB"},
		{id => 2, bookmark => 2, description => "this is folderC"},
		{id => 3, bookmark => 4, description => "this is folderE"},
		{id => 4, bookmark => 5, description => "this is folderF"},
		{id => 5, bookmark => 6, description => "this is folderG"},
		{id => 6, bookmark => 9, description => "this is folderJ"},
	],
);
ok(scalar @Folders, "inserting folders into database");

# create some links
my $link_rs = $schema->resultset("Link");
my @Links = $link_rs->populate
(
	[
		{id => 0, url => "http://digg.com", bookmark => 3},
		{id => 1, url => "http://slashdot.com", bookmark => 7},
		{id => 2, url => "http://reddit.com", bookmark => 8},
		{id => 3, url => "http://google.com", bookmark => 10},
		{id => 4, url => "http://wikipedia.com", bookmark => 11},
		{id => 5, url => "http://perl.com", bookmark => 12},
	],
);
ok(scalar @Links, "inserting links into database");

# add some tags 
my $tag_rs = $schema->resultset("Tag");
my @Tags = $tag_rs->populate
(
	[
		{id => 0, tag => "social news"},
		{id => 1, tag => "programming"},
		{id => 2, tag => "reference"},
		{id => 3, tag => "search"},
		{id => 4, tag => "technology"},
	],
);
ok(scalar @Tags, "inserting tags into database");

# add some tags to links
my $linktag_rs = $schema->resultset("LinkTag");
my @LinkTags = $linktag_rs->populate
(
	[
		{tag => 0, link => 0},
		{tag => 0, link => 1},
		{tag => 0, link => 2},
		{tag => 1, link => 5},
		{tag => 2, link => 4},
		{tag => 3, link => 3},
		{tag => 4, link => 0},
		{tag => 4, link => 5},
	],
);
ok(scalar @LinkTags, "adding tags to links");

