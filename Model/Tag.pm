package Model::Tag;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("tag");

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
	'tag' =>
	{
		'accessor' => 'tag',
		'data_type' => 'VARCHAR',
		'size' => 50,
		'is_nullable' => 0,
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many("tag_links" => "Model::LinkTag", "tag");
__PACKAGE__->many_to_many("links" => "tag_links", "link");

1;
