package Schema;

use base qw/DBIx::Class::Schema/;

use Exception;
use Exception::Server::Types;

# set default exception handler
__PACKAGE__->exception_action
(
	sub 
	{ 
		my $e = shift;

		# if $e is an exception object, re-throw
		$e->throw if ref $e && $e->can('throw');

		# otherwise, generate a new exception and throw
		throw Exception::Server::Database($e);
	}
);

__PACKAGE__->load_classes({"Model" => [qw/User Bookmark Folder Link File Tag LinkTag FileUser/]});

1;
