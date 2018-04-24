package t::Analizo::Batch::Runner::Sequential;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;

use Analizo::Batch::Runner::Sequential;
use Analizo::Batch;
use Analizo::Batch::Job;
use Analizo::Batch::Output;

sub constructor : Tests {
  my $obj = __create();
  isa_ok($obj, 'Analizo::Batch::Runner');
  isa_ok($obj, 'Analizo::Batch::Runner::Sequential');
}

sub empty_batch_wont_crash : Tests {
  my $batch = Analizo::Batch->new;
  my $output = Analizo::Batch::Output->new;

  my $runner = __create();
  $runner->run($batch, $output);
}

sub run : Tests {
  my $batch = mock(Analizo::Batch->new);
  my $job1 = mock(Analizo::Batch::Job->new);
  my $job2 = mock(Analizo::Batch::Job->new);
  my $output = mock(Analizo::Batch::Output->new);

  $batch->set_series('next', $job1, $job2, undef);
  my $job1_executed = 0;
  $job1->mock('execute', sub { $job1_executed++ });
  my $job2_executed = 0;
  $job2->mock('execute', sub { $job2_executed++ });
  my @jobs_pushed = ();
  $output->mock('push', sub { push @jobs_pushed, $_[1] });
  my $output_flushed = 0;
  $output->mock('flush', sub { $output_flushed++ });

  my $runner = __create();
  $runner->run($batch, $output);

  ok($job1_executed == 1, 'job1 must be executed');
  ok($job2_executed == 1, 'job2 must be executed');
  is_deeply(\@jobs_pushed, [$job1, $job2]);
  ok($output_flushed == 1, 'output must be flushed exactly once');
}

sub __create {
  Analizo::Batch::Runner::Sequential->new;
}

__PACKAGE__->runtests;
