package Analizo::Command::metrics_batch;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Batch::Directories;
use Analizo::Batch::Output::CSV;
use File::Basename;

# ABSTRACT: processes several source code directories in batch

=head1 NAME

analizo-metrics-batch - processes several source code directories in batch

=head1 USAGE

  analizo metrics-batch [OPTIONS] [<input> [<input> ...]]

=cut

sub usage_desc { "%c metrics-batch %o [<input> [<input> ...]]" }

sub command_names { qw/metrics-batch/ }

sub opt_spec {
  return (
    [ 'output|o=s',   'output file name', { default => 'metrics.csv' } ],
    [ 'quiet|q',      'supresses messages to standard output' ],
    [ 'parallel|p=i', 'activates support for parallel processing' ],
  );
}

sub validate {
  my ($self, $opt, $args) = @_;
  if ($opt->output && ! -w dirname($opt->output)) {
    $self->usage_error("Output is not writable!");
  }
}

sub execute {
  my ($self, $opt, $args) = @_;
  my $runner = undef;
  if ($opt->parallel) {
    require Analizo::Batch::Runner::Parallel;
    $runner = new Analizo::Batch::Runner::Parallel($opt->parallel);
  } else {
    require Analizo::Batch::Runner::Sequential;
    $runner = new Analizo::Batch::Runner::Sequential;
  }
  unless ($opt->quiet) {
    $runner->progress(
      sub {
        my ($job, $done, $total) = @_;
        printf("I: Processed %s.\n", $job->id);
      }
    );
  }
  my $batch = new Analizo::Batch::Directories(@$args);
  my $output = new Analizo::Batch::Output::CSV;
  $output->file($opt->output);
  $runner->run($batch, $output);
}

=head1 DESCRIPTION

Processes several source code directories in batch running B<analizo metrics>
for each and optionally consolidating the results in a single data file.

B<analizo metrics-batch> is useful when you want to analyze several projects at
once, or several different versions of the same project. You pass a list of
directories in the command line and each one will be analyzed as a separate
project. If no directories are passed in the command line, all of the
subdirectories of the current directory will be analized.

For example, suppose you want to process 5 consecutive releases of
I<myproject>, from version 0.1.0 to 0.5.0.

=over

=item

First you unpack the release tarballs for those versions in a directory, say
/tmp/analysis:

  $ ls -1 /tmp/analysis
  myproject-0.1.0
  myproject-0.2.0
  myproject-0.3.0
  myproject-0.4.0
  myproject-0.5.0

=item

Then you change to that directory, and then run B<analizo metrics-batch>:

  $ cd /tmp/analysis
  $ analizo metrics-batch

=item

B<analizo metrics-batch> will collect the metrics
data in a single .csv file, that you can import in spreadsheet software or
statistical packages.

=back

analizo metrics-batch is part of the analizo suite.

=head1 OPTIONS

=over

=item --parallel N, -p N

Activates support for parallel processing, using I<N> concurrent worker
processes. Usually you will want N to be less than or equal to the number of
CPUs in your machine.

Note that analizo metrics extraction is a CPU-intensive process, so setting N
as the exacty number of CPUs you have may bring your machine to an unusable
state.

=item --output <file>, -o <file>

Write output to <file>. Default is to write to I<metrics.csv>. That file can
then be opened in data analysis programs.

=item --quiet, -q

Supresses messages to standard output.

=back

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
