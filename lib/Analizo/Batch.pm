use strict;
use warnings;

package Analizo::Batch;

sub new {
  my ($class) = @_;
  return bless {}, $class;
}

# This method must be overriden by subclasses, and must return a object that
# inherits from Analizo::Job representing the next job to be processed in this
# batch. If there are no pending jobs, i.e. all jobs contained by this job were
# already returns, then this method must return I<undef> to signal the end of
# the batch.
sub next {
  return undef;
}

1;
