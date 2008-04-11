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
__PACKAGE__->belongs_to("file" => "Model::File");

# define optional one-to-one relationships
__PACKAGE__->might_have("bookmark_folder", "Model::Folder", "id");
__PACKAGE__->might_have("bookmark_link", "Model::Link", "id");

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub get_descendents
{
	my ($this, $children) = @_;

	my $model = Controller->get_model();
	my $logger = Logger->get_logger();

	$children
		? $logger->debug("getting children for bookmark " . $this->id())
		: $logger->debug("getting descendents for bookmark " . $this->id());

	my $args = 
	{
		file => $this->get_column('file'),
		lft => {-between => [$this->lft(), $this->rgt()]},
	};
	
	$args->{level} = $this->level() + 1
		if $children;

	return $model->resultset('Bookmark')->search($args);
}

1;
