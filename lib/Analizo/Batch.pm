use strict;
use warnings;

package Analizo::Batch;

sub new {
  my ($class, @options) = @_;
  return bless { @options }, $class;
}

# This method must be overriden by subclasses, and must return a object that
# inherits from Analizo::Job representing the next job to be processed in this
# batch. If there are no pending jobs, i.e. all jobs contained in this batch
# were already returned, then this method must return I<undef> to signal the
# end of the batch.
#
# All jobs returned here MUST have an B<id> set, and it must be unique inside
# the current batch. This can be done with $job->id('SOMEJODIB').
sub next {
  return undef;
}

1;
