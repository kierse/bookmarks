package Handler::Server;

use strict;
use warnings;

use Controller;
use Exception::Client::Types;
use Logger;

use base qw/Handler/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

my $version = "0.0.1";

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub version
{
	my ($server, $request, $response) = @_;

	my $logger = Logger->get_logger();
	$logger->info("request for server version");

	$response->append($version);
	$response->status(1);
}

1;
