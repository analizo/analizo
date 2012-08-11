package Analizo::Batch;
use strict;
use warnings;

use base qw( Analizo::Filter::Client );

sub new {
  my ($class, @options) = @_;
  return bless { @options }, $class;
}

sub next {
  my ($self) = @_;
  my $next_job = $self->fetch_next();
  if ($next_job) {
    $self->share_filters_with($next_job);
  }
  return $next_job;
}

# This method must be overriden by subclasses, and must return a object that
# inherits from Analizo::Job representing the next job to be processed in this
# batch. If there are no pending jobs, i.e. all jobs contained in this batch
# were already returned, then this method must return I<undef> to signal the
# end of the batch.
#
# All jobs returned here MUST have an B<id> set, and it must be unique inside
# the current batch. This can be done with $job->id('SOMEJODIB').
sub fetch_next {
  return undef;
}

# This method must be overriden by subclasses and return the total amount of
# jobs in this batch.
sub count {
  return undef;
}

1;
