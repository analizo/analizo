package BatchRunnerTests;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More qw(no_plan);
use t::Analizo;

use Analizo::Batch::Runner;
use Analizo::Batch::Output;

sub interface : Tests {
  can_ok('Analizo::Batch::Runner', 'run');
  can_ok('Analizo::Batch::Runner', 'actually_run');
}

sub interaction_with_output : Tests {
  my $runner = new Analizo::Batch::Runner;
  my $batch = {};
  my $output = mock(new Analizo::Batch::Output);

  my $initialized = 0;
  my $flushed = 0;
  $output->mock('initialize', sub { $initialized = 1; });
  $output->mock('flush', sub { $flushed = 1; });

  $runner->run($batch, $output);

  ok($initialized, 'must initialize output object');
  ok($flushed, 'must flush output object');
}

sub progress : Tests {
  my $runner = new Analizo::Batch::Runner;
  my $job = undef;
  my $step = undef;
  my $total = undef;
  $runner->progress(sub { my ($j, $i, $n) = @_; $job = $j; $step = $i; $total = $n; });

  my $_j = {};
  $runner->report_progress($_j, 33, 99);

  is($job, $_j);
  is($step, 33);
  is($total, 99);
}


BatchRunnerTests->runtests;
