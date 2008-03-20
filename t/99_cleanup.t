#!/usr/bin/perl

use strict; use warnings;

use lib("..");
use Test::More qw/no_plan/;

my $testDB = "/tmp/test.db";

# clean up and remove test database
ok(unlink($testDB), "  cleanup: removing test database");

