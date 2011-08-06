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

# Runners must use this method to push jobs into the output object.
#
# Subclasses must override this method.
sub push {
}

# To which file the output must be written
__PACKAGE__->mk_accessors(qw(file));

# Makes any initialization needed for the given output driver.
#
# This method must be overriden by subclasses
sub initialize {
}

# Opens a file for output, delegates the actual writing to subclasses, and
# closes the file. If no file was given, write to standard output.
sub flush {
  my ($self) = @_;
  if ($self->file) {
    open(my $fh, '>', $self->file) or die("Could not open output file $self->file: $!");
    $self->write_data($fh);
    close($fh);
  } else {
    $self->write_data(*STDOUT);
  }
}

# Must be overriden by subclasses. Will receive a FILEHANDLE, and must write
# the data to it.
sub write_data {
}

1;
