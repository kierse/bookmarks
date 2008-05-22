package Exception;

use strict;
use warnings;

use base qw/Error/;

use Controller;
use Logger;

# variables - - - - - - - - - - - - - - - - - - - - - - - - -

# public methods- - - - - - - - - - - - - - - - - - - - - - -

sub new
{
	my ($class, $text, %Args) = @_;
	$text ||= "";

	my %Configs = Controller->get_configs();

	my ($package, $file, $line) = _get_caller();

	# populate exception fields
	$Args{"-text"} = $text;
	$Args{"-file"} = $file;
	$Args{"-line"} = $line;

	# add a couple custom fields
	$Args{"-package"} = $package;
	$Args{"-trace"} = Carp::longmess()
		if $Configs{'logging'}{'generate_stack_trace'};

	my $error = $class->SUPER::new(%Args);

	# if logger has been initialized, log exception
	if (Log::Log4perl->initialized())
	{
		my $logger = _get_logger();

		# grab name of invoking method
		my (undef, undef, undef, $method) = caller(0);
		if ($method eq "record")
		{
			$logger->warn($error->stringify(1));
		}
		else
		{
			$logger->error($error->stringify(1));
		}
	}

	return $error;
}

#sub record
#{
#	my ($C, @args) = @_;
#
#	# get error object...
#	my $error = $C->SUPER::record(@args);
#
#	if (Log::Log4perl->initialized())
#	{
#   	# get logger using caller namespace
#		my $logger = _get_logger();
#
#		# log error object 
#		$logger->warn($error->stringify(1));
#	}
#
#	return $error;
#}

sub stringify
{
	my ($this, $verbose) = @_;
	my $error = (ref $this) . ": " . $this->SUPER::stringify();

	if ($verbose)
	{
		$error .= " on line " . $this->{-line} . " of file " . $this->{-file} . "\n" .
					 "Trace:\n" .
					 $this->{-trace};
	}

	return $error;
}

sub throw
{
	my ($this, @args) = @_;

	if (ref $this && Log::Log4perl->initialized())
	{
		# get logger using caller namespace
		my $logger = _get_logger();

		# log error object...
		#$Log::Log4perl::caller_depth = 1;
		#Logger->set_caller_depth(1);
		$logger->error($this->stringify(1));
		#$Log::Log4perl::caller_depth = 0;
		#Logger->set_caller_depth(0);
	}

	$this->SUPER::throw(@args);
}

sub TO_JSON
{
	return $_[0]->stringify();
}

# private methods - - - - - - - - - - - - - - - - - - - - - -

# In order to successfully log all generated exceptions (both recorded and
# thrown ones) we need to have a logger.  But we don't want to require that
# a logger be passed when throwing an error (this won't work for auto
# generated errors).  Therefore, we have to traverse the call stack until
# we find a configured namespace.
sub _get_logger
{
	my $category;

	my $i = 0;
	while (($category) = caller ($i++))
	{
		$category =~ s/::/./g;
		$category = lc $category;
		last if Log::Log4perl::MDC->get($category);

		undef $category;
	}

	return Logger->get_logger($category);
}

# Because of the way that an exception is generated ie (throw Exception) the 
# actual object is created in the CPAN Error class.  Therefore, the default 
# -file and -line values (set when the Error object is created) are incorrect, 
# producing an inaccurate record of where the error was thrown.  To solve this,
# use Perl's caller method (which returns the context of the current method 
# call) and use its values to populate the error objects fields
sub _get_caller
{
	my $package;
	my $file;
	my $line;

	my $logger = Logger->get_logger(__PACKAGE__)
		if Log::Log4perl->initialized();

	# because the Error new, throw, and record methods are overridden,
	# there is a predictable series of calls (3 to be exact) that all 
	# follow the creation of every Exception object.  Therefore, the 
	# 4th entry on the call stack is the caller info we're looking for
	($package, $file, $line) = caller(3);

	$logger->debug("determined exception caller to be '$package'")
		if Log::Log4perl->initialized();

	# loop through the call stack and attempt to determine name of file
	# and line number where exception was generated.
#	my $i = 0;
#	while (($package, $file, $line) = caller ($i++))
#	{
#		print STDERR "p: $package, f: $file, l: $line\n";
#
#		# if the current package is either the Error or Exception class, skip them
#		if ($package =~ /Error|Exception/g)
#		{
#			$package = $file = $line = undef;
#		}
#
#		# we've found the source of the exception, break out
#		else
#		{
##			last;
#		}
#	}

	return ($package, $file, $line);
}

1;#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
