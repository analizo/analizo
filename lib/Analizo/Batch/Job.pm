# This class represents one execution of `analizo metrics` on the current
# directory. Subclasses must implement specific ways of obtaining the source
# code to be analysed.
package Analizo::Batch::Job;

use strict;
use warnings;
use parent qw(Class::Accessor::Fast Analizo::Filter::Client);
use File::Basename;
use File::Temp qw/ tempfile /;
use File::HomeDir;
use File::Spec;
use File::Temp qw/ tempdir /;

use CHI;

use Analizo::Model;
use Analizo::Extractor;
use Analizo::Metrics;

__PACKAGE__->mk_accessors(qw(model metrics id directory extractor));
__PACKAGE__->mk_accessors(qw(includedirs libdirs libs));

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

# Returns the same metadata as the B<metadata> method, but as a HASH reference
# instead of an ARRAY reference. For example, assume that B<metadata> returns
# the following:
#
#   [
#     ['field1', 'value1'],
#     ['field2', 10],
#   ]
#
# In this case, B<metadata_hashref> must return the following:
#
#   {
#     'field1' => 'value1',
#     'field2' => 10,
#   }
#
sub metadata_hashref($) {
  my ($self) = @_;
  my %hash = map { $_->[0] => $_->[1] } @{$self->metadata()};
  return \%hash;
}

sub execute {
  my ($self) = @_;

  $self->prepare();

  my $tree_id = $self->tree_id();

  # extract model from source
  my $model_cache_key = "model://$tree_id";
  my $model = $self->cache->get($model_cache_key);
  if (!defined $model) {
    $model = Analizo::Model->new;
    my %options = (
      model => $model,
      includedirs => $self->includedirs,
      libdirs => $self->libdirs,
      libs => $self->libs,
    );
    my @extractors = (
      Analizo::Extractor->load($self->extractor, %options),
    );
    for my $extractor (@extractors) {
      $self->share_filters_with($extractor);
      $extractor->process('.');
    }
    $model->graph;
    $self->cache->set($model_cache_key, $model);
  }
  $self->model($model);

  # calculate metrics
  my $metrics_cache_key = "metrics://$tree_id";
  my $metrics = $self->cache->get($metrics_cache_key);
  if (!defined $metrics) {
    $metrics = Analizo::Metrics->new(model => $self->model);
    $metrics->data();
    $self->cache->set($metrics_cache_key, $metrics);
  }
  $self->metrics($metrics);

  $self->cleanup();
}

sub project_name($) {
  my ($self) = @_;
  return basename($self->directory);
}

sub cache($) {
  my ($self) = @_;
  $self->{cache} ||= CHI->new(driver => 'File', root_dir => _get_cache_dir());
}

sub _get_cache_dir {
  if ($ENV{ANALIZO_CACHE}) {
    return $ENV{ANALIZO_CACHE};
  }

  # automated test environment should not mess with the real cache
  my @program_path = File::Spec->splitdir($0);
  if ($program_path[0] eq '.') {
    shift @program_path;
  }
  if ($program_path[0] eq 't') {
    return tempdir(CLEANUP => 1);
  }

  return File::Spec->catfile(File::HomeDir->my_home, '.cache', 'analizo')
}


sub tree_id($) {

  my ($self) = @_;
  my @input = sort($self->apply_filters('.'));

  my ($temp_handle, $temp_filename) = tempfile();
  foreach my $input_file (@input) {
    print $temp_handle "$input_file\n"
  }
  close $temp_handle;

  open(SHA1SUM, "cat $temp_filename | xargs sha1sum | sha1sum - |");
  my $id = <SHA1SUM>;
  chomp($id);
  $id =~ s/\s.*//;

  close SHA1SUM;
  unlink $temp_filename;

  return $id;
}

1;
