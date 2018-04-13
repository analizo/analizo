package t::Analizo::Batch::Runner::Parallel;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;

use Analizo::Batch::Runner::Parallel;

use Analizo::Batch::Runner::Sequential;
use Analizo::Batch::Output;
use Analizo::Batch::Directories;

sub constuctor : Tests {
  my $obj = __create();
  isa_ok($obj, 'Analizo::Batch::Runner');
  isa_ok($obj, 'Analizo::Batch::Runner::Parallel');
}

sub number_of_parallel_processes : Tests {
  my $default = __create();
  is($default->parallelism, 2);

  my $four = __create(4);
  is($four->parallelism, 4);
}

sub should_be_equivalent_to_sequential_runner : Tests {
  my $output_sequential = mock(Analizo::Batch::Output->new);
  my $output_parallel = mock(Analizo::Batch::Output->new);
  my @jobs_sequential = ();
  $output_sequential->mock('push', sub { my ($that, $job) = @_; push @jobs_sequential, $job->id; });
  my @jobs_parallel = ();
  $output_parallel->mock('push', sub { my ($that, $job) = @_; push @jobs_parallel, $job->id; });

  my $batch_sequential = Analizo::Batch::Directories->new(glob('t/samples/hello_world/*'));
  my $batch_parallel = Analizo::Batch::Directories->new(glob('t/samples/hello_world/*'));

  my $runner_sequential = Analizo::Batch::Runner::Sequential->new;
  my $runner_parallel = __create();

  $runner_sequential->run($batch_sequential, $output_sequential);
  $runner_parallel->run($batch_parallel, $output_parallel);

  @jobs_sequential = sort @jobs_sequential;
  @jobs_parallel = sort @jobs_parallel;

  is_deeply(\@jobs_parallel, \@jobs_sequential);
  is(scalar(@jobs_parallel), 4, 'must run 4 jobs');
}

sub __create {
  my @args = @_;
  Analizo::Batch::Runner::Parallel->new(@args);
}

__PACKAGE__->runtests;
