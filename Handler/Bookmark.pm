package Handler::Bookmark;

use strict;
use warnings;

use Controller;
use Exception::Client::Types;
use Logger;

use base qw/Handler/;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub import_tree
{
	my ($class, $request, $response) = @_;
	my $user = $request->token()->user();

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my $args = $request->args();

	# first things first, make sure user has write permission to modify the 
	# file they are trying to import into.  Retrieve the file and check users 
	# access level
	Model::File->get_by_key($args->[0]{file})->assert_access($user, 1);

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
	my $user = $request->token()->user();

	$class->SUPER::add(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my %SiblingsCache;
	foreach my $bookmark (@{$request->args()})
	{
		# before we proceed, make sure caller has permission
		# to make changes to current file
		my $file = Model::File->get_by_key($bookmark->{file});
		$file->assert_access($user, 1);

		# add bookmark method #1
		# caller has passed a series of arguments, each of which contains
		# hierarchy and positional information.  No need to do any calculations

		# add bookmark method #2
		# caller has passed a list of arguments which contain parent
		# and folder position information.  Need to translate this data
		# into lft and rgt values for storage in database.
		if (exists $bookmark->{_parent})
		{
			my $parent = $model->resultset('Bookmark')->find($bookmark->{_parent});

			$SiblingsCache{$parent} = [$parent->get_children()]
				unless exists $SiblingsCache{$parent};

			($bookmark->{lft}, $bookmark->{rgt}) = _calculate_nested_tree_values
			(
				$bookmark, 
				$parent, 
				@{$SiblingsCache{$parent}}
			);

			# remove _parent and _position data as they are 
			# no longer needed...
			delete $bookmark->{_parent};
			delete $bookmark->{_position};

			$bookmark->{level} = $parent->level() + 1;
		}

		# update revision number
		$file->update({revision => $file->revision() + 1});
		$bookmark->{revision} = $file->revision();

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
	my $user = $request->token()->user();

	$class->SUPER::update(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my %SiblingsCache;
	foreach my $bookmark (@{$request->args()})
	{
		# before we proceed, make sure caller has permission
		# to make changes to current file
		my $file = Model::File->get_by_key($bookmark->{file});
		$file->assert_access($user, 1);

		# things you can do to a bookmark:
		#  1. update title
		#  2. alter tree position
		#  3. change file (must include new tree position)

	}
}

sub delete
{
	my $class = shift;
	my ($request, $response) = @_;
	my $token = $request->token();

	$class->SUPER::delete(@_);

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	my $args = $request->args();

}

# private methods - - - - - - - - - - - - - - - - - - - - - -

sub _calculate_nested_tree_values
{
	my ($bookmark, $parent, @Siblings) = @_;

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	# if there aren't any siblings, it doesn't matter what
	# the set position is.  Calculate bookmark lft and rgt values
	# based on parent values
	my ($left, $right);
	if (not (my $size = scalar @Siblings))
	{
		$left = $parent->lft() + 1;
		$right = $parent->lft() + 2;
	}

	# check if bookmark position is 0
	elsif ($bookmark->{_position} == 0)
	{
		die $Siblings[0];
		$left = $Siblings[0]->lft();
		$right = $Siblings[0]->lft() + 1;
	}

	# check if bookmark position is last
	elsif ($size <= $bookmark->{_position})
	{
		$left = $Siblings[$size - 1]->lft();
		$right = $Siblings[$size - 1]->lft() + 1;
	}

	# bookmark position must fall between two existing 
	else
	{
		my $position = $bookmark->{_position};
		$left = $Siblings[$position]->lft();
		$right = $Siblings[$position]->lft() + 1;
	}

	return ($left, $right);
}

1;
