package Model::Tag;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("tag");

# define table columns
__PACKAGE__->add_columns
(
	'tag' =>
	{
		'accessor' => 'tag',
		'data_type' => 'VARCHAR',
		'size' => 50,
		'is_nullable' => 0,
	},
	'file' =>
	{
		'accessor' => 'file',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'bookmark' =>
	{
		'accessor' => 'bookmark',
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
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key(qw/tag file bookmark/);

# define any foreign key constraints
# format: local_field_name, Package namespace, foreign_field_name
__PACKAGE__->belongs_to("tag_file" => "Model::File", "file", {cascade_delete => 1});
__PACKAGE__->belongs_to("tag_bookmark" => "Model::Bookmark", "bookmark", {cascade_delete => 1});

1;
