package Model::PartOf;

use base qw/Model/;

# define required components
__PACKAGE__->load_components(qw/PK::Auto Core/);

# set database table name
__PACKAGE__->table("part_of");

# define table columns
__PACKAGE__->add_columns
(
	'folder' =>
	{
		'accessor' => 'folder',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'file' =>
	{
		'accessor' => 'file',
		'data_type' => 'INTEGER',
		'is_nullable' => 0,
	},
	'created' =>
	{
		'accessor' => 'created',
		'data_type' => 'DATETIME',
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
__PACKAGE__->set_primary_key(qw/folder file/);

# define any foreign key constraints
# format: local_field_name, Package namespace, foreign_field_name
__PACKAGE__->belongs_to("po_folder" => "Model::Folder", "folder");
__PACKAGE__->belongs_to("po_file" => "Model::File", "file");

1;
