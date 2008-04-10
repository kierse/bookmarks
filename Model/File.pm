package Model::File;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("file");

# define table columns
__PACKAGE__->add_columns
(
	'id' =>
	{
		'accessor' => 'id',
		'data_type' => 'INTEGER',
		'is_auto_increment' => 1,
	},
	'name' =>
	{
		'accessor' => 'name',
		'data_type' => 'VARCHAR',
		'size' => 50,
		'is_nullable' => 0,
	},
	'owner' =>
	{
		'accessor' => 'owner',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
#	'private' =>
#	{
#		'accessor' => 'private',
#		'data_type' => 'BOOLEAN',
#		'default_value' => 1,
#		'is_nullable' => 0,
#	},
	'created' =>
	{
		'accessor' => 'created',
		'data_type' => 'DATETIME',
		'default_value' => 'CURRENT_TIMESTAMP',
	},
	'modified' =>
	{
		'accessor' => 'modified',
		'data_type' => 'TIMESTAMP',
		'default_value' => 'CURRENT_TIMESTAMP',
	},
	'revision' =>
	{
		'accessor' => 'revision',
		'data_type' => 'INTEGER',
		'default_value' => 0,
		'extra' => { 'unsigned' => 1 },
	},
	'description' =>
	{
		'accessor' => 'description',
		'data_type' => 'TEXT',
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("id");

# make sure file name is unique
__PACKAGE__->add_unique_constraint(["name","owner"]);

# define any foreign key constraints
# format: local_field_name, Package namespace, foreign_field_name
__PACKAGE__->belongs_to("owner" => "Model::User");

# define one-to-many relationship with Model::Bookmark
__PACKAGE__->has_many("file_bookmarks" => "Model::Bookmark", "file");

# define many-to-many relationship with Model::User
__PACKAGE__->has_many("file_users" => "Model::FileUser", "file");
__PACKAGE__->many_to_many("users_who_have_access" => "file_users", "user");

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub assert_access 
{
	my ($this, $user, $modify) = @_;
	my $model = Controller->get_model();

	# if given user is the owner, we are done
	return 1 if $this->owner()->get_column("id") eq $user->id();

	my $access = $model->resultset('FileUser')->find
	(
		{
			file => $this->id(),
			user => $user->id(),
		},
	);

	# there are three posible options for modify flag:
	#  1. undefined - given user has access to current file (read or write)
	#  2. write == 1 - user has write permission (read permission implied)
	#  3. write == 0 - user specifically does not have write permission
	if (ref $access && $access->isa("Model::FileUser"))
	{
		if (defined $modify)
		{
			return 1 if $access->modify() eq $modify;
		}
		else
		{
			return 1 if $access;
		}
	}

	$modify
		? throw Exception::Server::PermissionDenied("You do not have permission to make changes to file '" . $this->name() . "'")
		: throw Exception::Server::PermissionDenied("You do not have permission to access file '" . $this->name() . "'");
}

sub has_access
{
	my $access;
	try
	{
		$access = assert_access(@_);
	}
	catch Exception::Server::PermissionDenied with
	{
		$access = 0;
	};

	return $access;
}

1;
