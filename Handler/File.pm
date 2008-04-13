package Handler::File;

use strict;
use warnings;

use Controller;
use Exception::Client::Types;
use Logger;

use base qw/Handler/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub add
{
	my $class = shift;
	my ($request, $response) = @_;
	my $user = $request->token()->user();

	$class->SUPER::add(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	# loop through given arguments and create new files
	my $resp;
	foreach my $rFile (@{$request->args()})
	{
		# grab temporary id
		my $tID = __PACKAGE__->_get_temporary_id($request, $rFile);

		$rFile->{owner} = $user->id();
		my $file = $model->resultset('File')->create($rFile);

		# add tID => ID pair to response
		$resp->{$tID} = $file->id();
	}

	push @{$response->args()}, $resp;

	# made it this far, set status to 1 on response
	$response->status(1);
}

sub update
{
	my $class = shift;
	my ($request, $response) = @_;
	my $user = $request->token()->user();

	$class->SUPER::update(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	foreach my $rFile (@{$request->args()})
	{
		throw Exception::Client::MissingRequestData($request->handler() . "->update requires a valid file name or id")
			unless defined $rFile->{"id"} || defined $rFile->{"name"};
		
		# retrieve the file being updated...
		my @Args;
		if (exists $rFile->{id})
		{
			@Args = ($rFile->{id});
		}
		{
			@Args = 
			(
				{
					name => $rFile->{"name"}, 
					owner => $user->id(),
				}, 
				{ key => 'file_name_owner' },
			);
		}

		my $file = Model::File->get_by_key(@Args);

		# sanitize given data to ensure caller isn't trying to update
		# any locked fields
		delete $rFile->{_update}{id};
		delete $rFile->{_update}{owner};

		# increment file revision number
		$rFile->{_update}{revision} = $file->revision() + 1;

		$file->update($rFile->{_update});
	}

	$response->status(1);
}

sub delete
{
	my $class = shift;
	my ($request, $response) = @_;
	my $user = $request->token()->user();

	$class->SUPER::delete(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	foreach my $file (@{$request->args()})
	{
		throw Exception::Client::MissingRequestData($request->handler() . "->delete requires a valid file name or id")
			unless defined $file->{"id"} || defined $file->{"name"};

		my @Args;
		if (exists $file->{id})
		{
			@Args = ($file->{id})
		}
		else
		{
			@Args = 
			(
				{
					name => $file->{name},
					owner => $user->id(),
				},
				{ key => 'file_name_owner' },
			);
		}

		# delete file
		my $file = Model::File->get_by_key(@Args);
		$file->delete();

		throw Exception::Server::Database("Deletion of file '$file->name()' failed")
			if $file->in_storage();
	}

	$response->status(1);
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
