package Model::User;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("user");

# define table columns
__PACKAGE__->add_columns
(
	'id' =>
	{
		'accessor' => 'id',
		'data_type' => 'INTEGER',
		'is_auto_increment' => 1,
	},
	'username' =>
	{
		'accessor' => 'username',
		'data_type' => 'VARCHAR',
		'size' => 15,
		'is_nullable' => 0,
	},
	'password' =>
	{
		'accessor' => 'password',
		'data_type' => 'VARCHAR',
		'size' => 25,
		'is_nullable' => 0,
	},
	'name' =>
	{
		'accessor' => 'name',
		'data_type' => 'VARCHAR',
		'size' => 50,
	},
	'email' =>
	{
		'accessor' => 'email',
		'data_type' => 'VARCHAR',
		'size' => 25,
	},
	'active' =>
	{
		'accessor' => '_active',
		'data_type' => 'BOOLEAN',
		'default_value' => 1,
		'is_nullable' => 0,
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("id");

# make sure username is unique
__PACKAGE__->add_unique_constraint(["username"]);

# declare any one-to-many relationships
__PACKAGE__->has_many("owns_files" => "Model::File", "owner");

# define many-to-many relationship with Model::File
__PACKAGE__->has_many("user_files" => "Model::FileUser", "user");
__PACKAGE__->many_to_many("access_to_files" => "user_files", "file");

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub get_files
{
	my ($this, $modify) = @_;
	my $model = Controller->get_model();

	my $or_clause = [owner => $this->id()];
	if (defined $modify)
	{
		my $and_clause = 
		[
			'file_users.user' => $this->id(),
			'file_users.modify' => $modify,
		];

		push @$or_clause, "-and" => $and_clause;
	}
	else
	{
		push @$or_clause, 'file_users.user' => $this->id();
	}

	# retrieve files where current user is:
	# 	a) owner, or
	# 	b) has access to (via FileUser table)
	return $model->resultset("File")->search
	(
		{-or => $or_clause},
		{
			join => ["file_users"],
		}
	);
}

sub encrypt_password 
{
	my ($class, $password) = @_;

	# ATTENTION - this needs to be implemented!!!
	return $password;
}

sub verify_password
{
	my ($this, $password) = @_;

	return $this->password() eq __PACKAGE__->encrypt_password($password);
}

1;
