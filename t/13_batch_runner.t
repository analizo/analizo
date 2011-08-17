package BatchRunnerTests;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More qw(no_plan);
use Test::Analizo;

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


BatchRunnerTests->runtests;
