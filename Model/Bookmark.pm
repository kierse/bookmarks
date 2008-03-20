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
		'is_nullable' => 0,
	},
	'url' =>
	{
		'accessor' => 'url',
		'data_type' => 'VARCHAR',
		'size' => 256,
		'is_nullable' => 0,
	},
	'title' =>
	{
		'accessor' => 'title',
		'data_type' => 'VARCHAR',
		'size' => 256,
	},
	'icon' =>
	{
		'accessor' => 'icon',
		'data_type' => 'VARCHAR',
		'size' => 256,
	},
	'folder' =>
	{
		'accessor' => 'folder',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
	'position' =>
	{
		'accessor' => 'position',
		'data_type' => 'INTEGER',
		'default_value' => 0,
		'extra' => { 'unsigned' => 1 },
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
	'keywords' =>
	{
		'accessor' => 'keywords',
		'data_type' => "VARCHAR",
		'size' => 256,
	},
	'description' =>
	{
		'accessor' => 'description',
		'data_type' => 'TEXT',
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("id");

# define any foreign key constraints
__PACKAGE__->belongs_to("bookmark_folder" => "Model::Folder", "folder", {cascade_delete => 1});

# define many-to-many relationship with Model::File
__PACKAGE__->has_many("bookmark_files" => "Model::Tag", "bookmark");
__PACKAGE__->many_to_many("files" => "bookmark_files", "tag_file");

1;
