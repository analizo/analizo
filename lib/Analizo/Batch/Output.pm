# This class represents an possible output format for analizo operations.  It
# has the responsibility to generate an output based on a series of jobs, and to inform
#
package Analizo::Batch::Output;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);

sub new {
  my ($class) = @_;
  return bless {}, $class;
}

# This method must be overriden by subclasses, and must return 0 or 1 based on
# whether the given output format requires calculation of metrics or not.
#
# Given that calculating metrics requires a significant amount of processing,
# by default we return 0 here.
sub requires_metrics {
  0;
}

1;
