package Message::Token;

use strict;
use warnings;

use Log::Log4perl;

use Controller;
use Exception;
use Exception::Client::Types;

use base qw/Message/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

our $AUTOLOAD;

# field declaration - - - - - - - - - - - - - - - - - - - - -

my $fields = 
{
	user => undef
};

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	my ($class, $token) = @_;

	throw Exception::Client::MissingTokenData("Invalid or missing token data")
		unless ref $token eq "HASH";

	# verify that raw token includes a username
	throw Exception::Client::MissingTokenData("Token missing username or id")
		unless defined $token->{username} or defined $token->{id};

	# verify that raw token includes a password
	throw Exception::Client::MissingTokenData("Token missing password")
		unless defined $token->{password};

	my $model = Controller->get_model();

	# use username and password and retrieve user object from database
	my $user = $token->{id}
		? $model->resultset('User')->find($token->{id})
		: $model->resultset('User')->find($token->{username}, {key=>"user_username"});

	# verify that given password is valid
	throw Exception::Client::InvalidCredentials("Username and/or password is incorrect")
		unless $user->verify_password($token->{password});
	
	my $this = $class->SUPER::new($fields);
	$this->user($user);

	return $this;
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
