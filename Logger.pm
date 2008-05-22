package Logger;

use strict; use warnings;

use Log::Log4perl;

# class variables- - - - - - - - - - - - - - - - - - - - - - -

our @ISA = qw(Log::Log4perl);

#$Log::Log4perl::caller_depth = 1;

# public methods - - - - - - - - - - - - - - - - - - - - - - -

sub init
{
	shift;
	return Log::Log4perl->init(@_);
}

sub get_logger
{
	my ($class, $category) = @_;
	($category) ||= caller;

	my $logger = Log::Log4perl->get_logger($category);
	unless (Log::Log4perl::MDC->get($category))
	{
		$logger->debug("registering category '$category' with MDC");

		# Register current category with Log4perl MDC (mapped diagnostic context)
		# Note: this feature is used by exception objects to locate most recent
		# caller that has a configured logger.
		Log::Log4perl::MDC->put($category, 1);
	}

	return $logger;
}

sub set_caller_depth
{
	shift;
	$Log::Log4perl::caller_depth = shift;
}

# private methods- - - - - - - - - - - - - - - - - - - - - - -

1;#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
