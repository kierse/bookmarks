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

sub get_by_id
{
	my $type = shift;
	return $type->get_by_key(@_);
}

sub get_by_key
{
	my ($type, @Args) = @_;
	my $model = Controller->get_model();

	# get object type from calling class
	$type =~ s/^Model::(\w+)$/$1/g;

	my $obj = $model->resultset($type)->find(@Args);
	
	throw Exception::Server::ObjectNotFound("Unable to find $type object")
		unless ref $obj;

	return $obj;
}


sub TO_JSON
{
	my ($this) = @_;
	my %serializedData = map { $_ => $this->$_() } $this->columns();

	return \%serializedData;
}

1;
