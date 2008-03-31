package Schema;

use base qw/DBIx::Class::Schema/;

use Exception;
use Exception::Server::Types;

# set default exception handler
__PACKAGE__->exception_action(sub { throw Exception::Server::Database(@_); print ""; });

__PACKAGE__->load_classes({"Model" => [qw/User Bookmark Folder Link File Tag LinkTag/]});

1;
