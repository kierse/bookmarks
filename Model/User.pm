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
__PACKAGE__->has_many("user_files" => "Model::File", "owner");

# public methods- - - - - - - - - - - - - - - - - - - - - - -

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
