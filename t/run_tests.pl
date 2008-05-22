#!/usr/bin/perl

use strict; 
use warnings;

use Cwd;
use TAP::Harness;

# make sure a few default environment variable are set
$ENV{"BOOKMARKS_CONFIG_PATH"} ||= getcwd() . "/../conf";
$ENV{"BOOKMARKS_LOG_PATH"} ||= getcwd() . "/../log";
$ENV{"BOOKMARKS_ENV"} = "test-harness";
$ENV{"BOOKMARKS_PORT"} ||= 8080;

# gather list of tests
opendir(TESTS, ".") || die "Unable to read from test ('t') directory: $!";
my @Tests = sort grep { /.t$/ and -x $_ } readdir(TESTS);
closedir(TESTS);

my $filter = join("|", @ARGV) if @ARGV;
@Tests = grep {/$filter/} @Tests if $filter;

# create a test harness and run tests
my $harness = TAP::Harness->new({"verbosity" => 1});
$harness->runtests(@Tests);

