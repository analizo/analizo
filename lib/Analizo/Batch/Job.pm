# This class represents one execution of `analizo metrics` on the current
# directory. Subclasses must implement specific ways of obtaining the source
# code to be analysed.
package Analizo::Batch::Job;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use File::Basename;

use Analizo::Extractor;
use Analizo::Metrics;

__PACKAGE__->mk_accessors(qw(model metrics id directory));

sub new {
  my ($class, @options) = @_;
  return bless { @options }, $class;
}

# This method must be overriden by by subclasses.
#
# This method must do all the work required to leave the current process in the
# directory whose source code must be analysed. B<This may include changing the
# current directory>.
#
# Everything that is done in this method must be undone in the I<cleanup>
# method.
sub prepare {
}

# This method must be overriden by by subclasses.
#
# This method must clean up after the I<prepare> method. For example, if
# I<prepare> chenged the working directory of the current process, cleanup must
# change the working directory back to the working directory that was the
# current before I<prepare> runs.
sub cleanup {
}

# When this method is called, the job must activate its mode for safe parallel
# processing. When such mode is activated, the job must be prepared, executed
# and cleaned in a way that it is possible to process several jobs in parallel.
# This means for example that if any change is required in the directory where
# the job will run, the job must first make copy of that directory and operate
# over it instead of operating over the original directory.
#
# Analizo's parallelism model uses separate PROCESSES and not separate threads.
# This is due to the fact that to process some jobs, Analizo will need to
# chdir() into different directories, and if we used threads this would cause
# problems since the current work directory is shared by all threads, and
# therefore one thread would interfere with the others when using chdir().
#
# This method must be inherited by subclasses.
#
# When called, it will be called BEFORE the B<prepare> method. After the first
# job has its B<parallel_prepare> method called, any subsequent invocations of
# this method on jobs in the same process must be indepotent.
sub parallel_prepare {
}

# This method must cleanup any resources that may have been created to support
# parallel execution. Such resources were probably allocated by the
# B<parallel_safe> method.
#
# This method will not be called for all jobs in a given batch. I will be
# called only for the last job in the batch for the current process, which will
# be responsible for releasing any resources that were created for supporting
# the execution of jobs by a given process.
sub parallel_cleanup {
}

# This method must return metadata about this job, in the form of an ARRAY
# reference.  Each element of the ARRAY must be itself an ARRAY with two
# elements, the first the name of the field and the second the value of the
# field. Both field names and values must be SCALARs. Example:
#
#   return [
#     ['field1', 'value1'],
#     ['field2', 10],
#   ];
#
# The implementation in this class returns an empty ARRAY reference.  This
# method may be overriden by subclasses.
sub metadata {
  []
}

sub execute {
  my ($self) = @_;

  $self->prepare();

  # extract model from source
  my $extractor = Analizo::Extractor->load();
  $extractor->process('.');
  $self->model($extractor->model);

  # calculate metrics
  $self->metrics(new Analizo::Metrics(model => $self->model));
  $self->metrics->data();

  $self->cleanup();
}

sub project_name($) {
  my ($self) = @_;
  return basename($self->directory);
}


1;
