package BatchRunnerTests;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More qw(no_plan);

use Analizo::Batch::Runner;

sub output : Tests {
  my $runner = new Analizo::Batch::Runner;
  my $output = {};
  $runner->output($output);
  is($runner->output, $output);
}

sub interface : Tests {
  can_ok('Analizo::Batch::Runner', 'run');
}


BatchRunnerTests->runtests;
