package Analizo::Batch::Runner;

use base qw(Class::Accessor::Fast);

sub new {
  my ($class) = @_;
  return bless {}, $class;
}

__PACKAGE__->mk_accessors(qw(output));

# must be implemented by subclasses. Will receive as argument:
#   * the batch to be run
#   * the output object
#
# This method must iterate over the jobs in some way, depending on the strategy
# employed by the subclass, and call I<execute> on each job, and feed the job
# object to the $output object by calling I<$output->push($job)>.
sub run {
}

1;
