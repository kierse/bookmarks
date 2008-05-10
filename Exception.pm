package Exception;

use strict;
use warnings;

use base qw/Error/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	return $_[0]->SUPER::new(-text => $_[1] || "");
}

sub stringify
{
	my ($this) = @_;

	return (ref $this) . ": " . $this->SUPER::stringify();
}

sub TO_JSON
{
	return $_[0]->stringify();
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
