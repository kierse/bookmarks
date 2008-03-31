package Handler::File;

use strict;
use warnings;

use Exception;
use Exception::Client::Types;
use Controller;

use base qw/Handler/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub add
{
	my $class = shift;
	my ($request, $response) = @_;

	$class->SUPER::add(@_);

	my $model = Controller->get_model();
	my $logger = Controller->get_configs();

	my $args = $request->args();

	# create new file using request data
	my $file = $model->resultset('File')->create($args->[0]);

	return unless ref $file;

	# made it this far, set status to 1 on response
	$response->status(1);
}

sub update
{
	my $class = shift;
	my ($request, $response) = @_;
	my $token = $request->token();

	$class->SUPER::update(@_);

	my $model = Controller->get_model();
	my $logger = Controller->get_configs();

	my $args = $request->args();

	throw Exception::Client::MissingRequestData(__PACKAGE__ . "::update requires a valid file name or id")
		unless defined $args->[0]{"id"} || defined $args->[0]{"name"};
	
	# retrieve the file being updated...
	my $file = $args->[0]{"id"}
		? $model->resultset('File')->find($args->[0]{"id"})
		: $model->resultset('File')->find({name => $args->[0]{"name"}, owner => $token->user()->id()}, {key=>'file_name_owner'});

	return unless ref $file;

	# sanitize given data to ensure caller isn't trying to update
	# any locked fields
	delete $args->[1]{"id"};
	delete $args->[1]{"owner"};

	# attempt to update file object using given data
	# set status on response object with results of update
	$file->update($args->[1]);
	$response->status(1);
}

sub delete
{
	my $class = shift;
	my ($request, $response) = @_;
	my $token = $request->token();

	$class->SUPER::delete(@_);

	my $model = Controller->get_model();
	my $logger = Controller->get_configs();

	my $args = $request->args();

	throw Exception::Client::MissingRequestData(__PACKAGE__ . "::delete requires a valid file name or id")
		unless defined $args->[0]{"id"} || defined $args->[0]{"name"};

	my $file;
	if ($args->[0]{"id"})
	{
		$file = $model->resultset('File')->find($args->[0]{"id"});
	}
	else
	{
		my @Files = $model->resultset('File')->find({name => $args->[0]{"name"}, owner => $token->user()->id()}, {key=>'file_name_owner'});
		if (scalar @Files)
		{
			$file = (scalar @Files == 1)
				? pop @Files
				: throw Exception::Client::InvalidRequest("Given file name is not unique");
		}
	}

	throw Exception::Client::InvalidRequest("No file by the name of '$args->[0]{name}' found")
		unless ref $file;

	# delete file
	$file->delete();

	# set the response status to 1 unless the file
	# object wasn't deleted
	$response->status(1) unless $file->in_storage();
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
