package Model::Folder;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("folder");

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
	'lft' =>
	{
		'accessor' => 'left',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'rgt' =>
	{
		'accessor' => 'right',
		'data_type' => 'INTEGER',
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

# define many-to-many relationship with Model::File
__PACKAGE__->has_many("folder_bookmarks" => "Model::Bookmark", "folder");
__PACKAGE__->has_many("folder_files" => "Model::PartOf", "folder");
__PACKAGE__->many_to_many("files" => "folder_files", "po_file");

1;
