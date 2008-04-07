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

# IMPORT new folder structure
my $request1 = 
{
	token => { username => 'userA', password => 'pass' },
	handler => "Folder",
	method => "import",
	args => 
	[
		{
			name => "dirA",
			lft => 1,
			rgt => 26,
			description => "dirA folder",
			folder_bookmarks =>
			[
				{ url => 'http://bookmark1.com' },
			],
		},
		{
			name => "dirB",
			lft => 2,
			rgt => 3,
			description => "dirB folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark2.com' },
				{ url => 'http://bookmark3.com' },
				{ url => 'http://bookmark4.com' },
				{ url => 'http://bookmark5.com' },
				{ url => 'http://bookmark6.com' },
			],
		},
		{
			name => "dirC",
			lft => 4,
			rgt => 21,
			description => "dirC folder",
			folder_bookmarks => [],
		},
		{
			name => "dirD",
			lft => 22,
			rgt => 25,
			description => "dirD folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark7.com' },
				{ url => 'http://bookmark8.com' },
				{ url => 'http://bookmark9.com' },
			],
		},
		{
			name => "dirE",
			lft => 5,
			rgt => 10,
			description => "dirE folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark10.com' },
			],
		},
		{
			name => "dirF",
			lft => 11,
			rgt => 20,
			description => "dirF folder",
			folder_bookmarks => [],
		},
		{
			name => "dirG",
			lft => 23,
			rgt => 24,
			description => "dirG folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark11.com' },
			],
		},
		{
			name => "dirH",
			lft => 6,
			rgt => 7,
			description => "dirH folder",
			folder_bookmarks => [],
		},
		{
			name => "dirI",
			lft => 8,
			rgt => 9,
			description => "dirI folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark12.com' },
				{ url => 'http://bookmark13.com' },
			],
		},
		{
			name => "dirJ",
			lft => 12,
			rgt => 13,
			description => "dirJ folder",
			folder_bookmarks => [],
		},
		{
			name => "dirK",
			lft => 14,
			rgt => 17,
			description => "dirK folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark14.com' },
				{ url => 'http://bookmark15.com' },
				{ url => 'http://bookmark16.com' },
				{ url => 'http://bookmark17.com' },
			],
		},
		{
			name => "dirL",
			lft => 18,
			rgt => 19,
			description => "dirA folder",
			folder_bookmarks => [],
		},
		{
			name => "dirM",
			lft => 15,
			rgt => 16,
			description => "dirM folder",
			folder_bookmarks => 
			[
				{ url => 'http://bookmark18.com' },
			],
		},
	],
};

my $request2 = 
{
	token => { username => 'userA', password => 'pass' },
	handler => "Folder",
	method => "import",
	args => 
	[
		{
			name => "dirA",
			description => "dirA folder",
			children => 
			[
				{
					name => "dirB",
					description => "dirB folder",
					children => [],
				},
				{
					name => "dirC",
					description => "dirC folder",
					children => 
					[
						{
							name => "dirE",
							description => "dirE folder",
							children => 
							[
								{
									name => "dirH",
									description => "dirH folder",
									children => [],
								},
								{
									name => "dirI",
									description => "dirI folder",
									children => [],
								},
							],
						},
						{
							name => "dirF",
							description => "dirF folder",
							children =>
							[
								{
									name => "dirJ",
									description => "dirJ folder",
									children => [],
								},
								{
									name => "dirK",
									description => "dirK folder",
									children =>
									[
										{
											name => "dirM",
											description => "dirM folder",
											children => [],
										},
									],
								},
								{
									name => "dirL",
									description => "dirA folder",
									children => [],
								},
							],
						},
					],
				},
				{
					name => "dirD",
					description => "dirD folder",
					children => 
					[
						{
							name => "dirG",
							description => "dirG folder",
						},
					],
				},
			],
		},
	],
};

my $response = Controller->request($request);
my $model = Controller->get_model();

SKIP:
{
	skip "create failed, further checks unnecessary"
		unless ok($response->status() eq 1, "CREATE new folder hierarchy");

}

diag $response->error()->stringify() if $response->status eq -1;

$request = 
(
	token => { username => 'userA', password => 'pass' },
	handler => "Folder",
	method => "add",
	args => 
	[
		{
			name => "dirM",
			lft => 15,
			rgt => 16,
			description => "dirM folder",
		},
	],
);
