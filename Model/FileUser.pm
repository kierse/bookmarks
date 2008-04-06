package Model::FileUser;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("fileuser");

# define table columns
__PACKAGE__->add_columns
(
	'file' =>
	{
		'accessor' => 'file',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
	'user' =>
	{
		'accessor' => 'user',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
	'modify' =>
	{
		'accessor' => 'modify',
		'data_type' => 'BOOLEAN',
		'default_value' => 0,
		'is_nullable' => 0,
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("file", "user");

# define any foreign key constraints
__PACKAGE__->belongs_to("file" => "Model::File");
__PACKAGE__->belongs_to("user" => "Model::User");

1;
