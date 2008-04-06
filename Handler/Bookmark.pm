package Handler::Bookmark;

use strict;
use warnings;

use Exception;
use Exception::Client::Types;
use Controller;

use base qw/Handler/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub buildHierarchy
{
	my ($class, $request, $response) = @_;

	my $model = Controller->get_model();
	my $logger = Controller->get_configs();

	my $args = $request->args();

	# import method #1
	# caller has passed a series of arguments, each of which contains
	# hierarchy and positional information.  No need to do any calculations
	# on the given lft and rgt values.
	my $bookmarks;
	if (exists $args->[0]{lft})
	{
		$bookmarks = $args;
	}

	# import method #2
	# caller has passed a nested list of arguments representing a physical 
	# hierarchy.  Traverse tree and gather lft and rgt values from given
	# structure and order.
	else
	{
		my $count = 0;
		my $level = 0;
		my $processTree;
		$processTree = sub
		{
			my $bookmark = shift;

			# set current tree level
			$bookmark->{level} = $level;

			# set current bookmarks lft value
			$bookmark->{lft} = $count++;

			my @Children;
			if ($bookmark->{_children})
			{
				# the current bookmark has children, increment
				# the level counter once BEFORE processing them...
				$level++;

				push @Children, &$processTree($_)
						foreach @{$bookmark->{_children}};

				# ...and decrement the level counter once AFTER
				# processing them
				$level--;
			}

			# set current bookmarks rgt value
			$bookmark->{rgt} = $count++;

			# delete _children key as it doesn't
			# exist in Model::Bookmark objects
			delete $bookmark->{_children};

			return ($bookmark, @Children);
		};

		my @List = &$processTree($args->[0]);
		$bookmarks = \@List;
	}

	# populate database with given bookmark hierarchy data
	$model->resultset('Bookmark')->populate($bookmarks);

	$response->status(1);
}

sub add
{
	my $class = shift;
	my ($request, $response) = @_;

	$class->SUPER::add(@_);

	my $model = Controller->get_model();
	my $logger = Controller->get_configs();

	my $args = $request->args();

	# grab list of files that user has access to

	my @Parents = map { $_->{_parent} } @$args;
	$model->resultset('Bookmark')->search
	(
		{file = 
	);

	my $bookmarks;
	my %Files;
	foreach my $bookmark (@$bookmarks)
	{
		my $fileID = $bookmark->{file};

		# before we proceed, make sure caller has permission
		# to make changes to current file
		unless ($Files{$fileID})
		{
			my $file = $model->resultset('Bookmark')->file($fileID);
			$file->canWrite($token->user())
				? $Files{$fileID} = 1
				: throw Exception::Client::PermissionDenied("You do not have permission to make changes to file '" . $file->name() . "'");
		}

		# add bookmark method #1
		# caller has passed a series of arguments, each of which contains
		# hierarchy and positional information.  No need to do any calculations

		# add bookmark method #2
		# caller has passed a list of arguments which contain parent
		# and folder position information.  Need to translate this data
		# into lft and rgt values for storage in database.
		if (not exists $bookmark->{lft})
		{
			my $parent = $model->resultset('Bookmark')->find($bookmark->{_parent});
			my $level = $parent->level() + 1;

			my @Siblings = $model->resultset('Bookmark')->search
			(
				{file => $bookmark->{file}},
				{level => $level},
				{lft => [$parent->lft(), $parent->rgt()]},
			);
		}


		my $left = $bookmark->{lft};
		my $right = $bookmark->{rgt};

		# alter tree to make room for current bookmark by:
		# 1. updating all nodes where rgt > $left - 1 to be rgt=rgt+2
		# 2. updating all nodes where lft > $left - 1 to be lft=lft+2
		my $dbh = $model->storage->dbh();

		my $sth = $dbh->prepare("UPDATE bookmark SET rgt=rgt+2 WHERE file=? AND rgt > ?");
		$sth->execute($bookmark->{file}, $left-1);

		$sth = $dbh->prepare("UPDATE bookmark SET lft=lft+2 WHERE file=? AND lft > ?");
		$sth->execute($bookmark->{file}, $left-1);

		$model->resultset('Bookmark')->create($bookmark);
	}

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

}

# private methods - - - - - - - - - - - - - - - - - - - - - -

1;
