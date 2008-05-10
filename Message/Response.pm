package Message::Response;

use strict;
use warnings;

use Log::Log4perl;

use base qw/Message/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

our $AUTOLOAD;

my $fields = 
{
	# fatal exception (if any) generated while processing request
	error => undef,

	# response data generated from a successful request
	# only present if error is unset
	args => [],

	# boolean value indicating overall status of request
	status => 0,

	# non-fatal error messages generated while processing request
	warnings => [],
};

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	__PACKAGE__->SUPER::new($fields);
}

sub append
{
	my ($this, @Args) = @_;

	push @{$this->args}, @Args;
}

sub add_warnings
{
	my ($this, @Warnings) = @_;

	push @{$this->warnings}, @Warnings;
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
