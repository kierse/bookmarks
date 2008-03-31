package Model::Link;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table('link');

# define table columns
__PACKAGE__->add_columns
(
	'id' =>
	{
		'accessor' => 'id',
		'data_type' => 'INTEGER',
		'is_auto_increment' => 1,
	},
	'url' =>
	{
		'accessor' => 'url',
		'data_type' => 'VARCHAR',
		'is_nullable' => 0,
	},
	'keyword' =>
	{
		'accessor' => 'keyword',
		'data_type' => 'VARCHAR',
	},
	'bookmark' =>
	{
		'accessor' => 'bookmark',
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
	'description' =>
	{
		'accessor' => 'description',
		'data_type' => 'TEXT',
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("id");

# make sure url is unique
__PACKAGE__->add_unique_constraint(["url"]);

# define any foreign key constraints
__PACKAGE__->belongs_to("bookmark" => "Model::Bookmark");

__PACKAGE__->has_many("link_tags" => "Model::LinkTag", 'link');
__PACKAGE__->many_to_many("tags" => 'link_tags', 'tags');

1;
