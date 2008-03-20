package Message;

use strict;
use warnings;

use Error;
use Log::Log4perl;

use Exception::Server::Types;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

our $AUTOLOAD;

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	my ($class, $fields) = @_;
	$fields ||= {};

#die join("\n", map { "$_ => " . ($fields->{$_}||"undef")} keys %$fields);

	return bless $fields, $class;
}

#sub fields
#{
#	shift;
#	map { $fields->{$_} = $_[0]{$_} } keys %{$_[0]};
#}

sub TO_JSON
{
	return { map {$_ => $_[0]->{$_}} keys %{$_[0]} };
}

sub AUTOLOAD
{
	my $this = shift;

	my $type = ref $this
		or throw Exception::Server::InvalidObject("Expected object, got '$this'");

	# get field name from value in $AUTOLOAD...
	my $name = $AUTOLOAD;
	$name =~ s/${type}:://g;

	return if $name eq "DESTROY";

	if (exists $this->{$name})
	{
		$this->{$name} = shift
			if @_;

		return $this->{$name};
	}
	else
	{
		throw Exception::Server::UnknownField("Can't access field '$name' in class type $type");
	}
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
