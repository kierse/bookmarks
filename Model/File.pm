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
		'is_nullable' => 0,
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
	'writeable' =>
	{
		'accessor' => 'writeable',
		'data_type' => 'BOOLEAN',
		'default_value' => 0,
		'is_nullable' => 0,
	},
	'private' =>
	{
		'accessor' => 'private',
		'data_type' => 'BOOLEAN',
		'default_value' => 1,
		'is_nullable' => 0,
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
__PACKAGE__->belongs_to("file_owner" => "Model::User", "owner", {cascade_delete => 1});

# define many-to-many relationship with Model::Folder
__PACKAGE__->has_many("file_folders" => "Model::PartOf", "file");
__PACKAGE__->many_to_many("folders" => "file_folders", "po_folder");

# define many-to-many relationship with Model::Bookmark
__PACKAGE__->has_many("file_bookmarks" => "Model::Tag", "file");
__PACKAGE__->many_to_many("bookmarks" => "file_bookmarks", "tag_bookmark");

1;
