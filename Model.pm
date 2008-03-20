package Model;

use base qw/DBIx::Class/;

sub TO_JSON
{
	my ($this) = @_;
	my %serializedData = map { $_ => $this->$_() } $this->columns();

	return \%serializedData;
}

1;
