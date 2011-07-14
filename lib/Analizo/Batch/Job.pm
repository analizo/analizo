# This class represents one execution of `analizo metrics` on the current
# directory. Subclasses must implement specific ways of obtaining the source
# code to be analysed.
package Analizo::Batch::Job;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);

use Analizo::Extractor;
use Analizo::Metrics;

__PACKAGE__->mk_accessors(qw(model metrics id));

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

  $self->cleanup();
}


1;
