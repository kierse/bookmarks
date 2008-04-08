package Model;

use strict;
use warnings;

use base qw/DBIx::Class/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	my ($class, $fields) = @_;
	$fields ||= {};

	return bless $fields, $class;
}

sub TO_JSON
{
	my ($this) = @_;
	my %serializedData = map { $_ => $this->$_() } $this->columns();

	return \%serializedData;
}

1;
