package Model::LinkTag;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("linktag");

# define table columns
__PACKAGE__->add_columns
(
	'tag' =>
	{
		'accessor' => 'tag',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
	'link' =>
	{
		'accessor' => 'link',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
		'is_foreign_key' => 1,
	},
);

# define table keys, including the primary key
__PACKAGE__->set_primary_key("tag", "link");

# define any foreign key constraints
__PACKAGE__->belongs_to("tag" => "Model::Tag");
__PACKAGE__->belongs_to("link" => "Model::Link");

1;
