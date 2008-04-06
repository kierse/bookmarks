package Model::Bookmark;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("bookmark");

# define table columns
__PACKAGE__->add_columns
(
	'id' =>
	{
		'accessor' => 'id',
		'data_type' => 'INTEGER',
		'is_auto_increment' => 1,
	},
	'title' =>
	{
		'accessor' => 'title',
		'data_type' => 'VARCHAR',
	},
	'lft' =>
	{
		'accessor' => 'lft',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'rgt' =>
	{
		'accessor' => 'rgt',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'level' =>
	{
		'accessor' => 'level',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'file' =>
	{
		'accessor' => 'file',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
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
#	'type' =>
#	{
#		'accessor' => 'type',
#		'data_type' => 'ENUM',
#
#		# not sure how to set other valid ENUM values
#		# available values: f (folder), s (separator), l (link)
#		'default_value' => 'l',
#		'is_nullable' => 0,
#	},
#	'description' =>
#	{
#		'accessor' => 'description',
#		'data_type' => 'TEXT',
#	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("id");

# make sure bookmark hierarchy position is unique to current file
#__PACKAGE__->add_unique_constraint(["lft", "rgt", "file"]);

# define any foreign key constraints
__PACKAGE__->belongs_to("file" => "Model::File", undef, {cascade_delete => 1});

# define optional one-to-one relationships
__PACKAGE__->might_have("bookmark_folder", "Model::Folder", "id");
__PACKAGE__->might_have("bookmark_link", "Model::Link", "id");

1;
