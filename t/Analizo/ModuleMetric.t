package t::Analizo::ModuleMetric;
use base qw(Test::Class);
use Test::More;
use Test::MockModule;

use strict;
use warnings;

use Analizo::ModuleMetric;

sub caches_calculate_results : Tests {
  my $AnalizoMetric = Test::MockModule->new('Analizo::ModuleMetric');

  my $metric = Analizo::ModuleMetric->new;

  $AnalizoMetric->mock('calculate', sub { return 1; });
  is($metric->value('MyModule'), 1);

  $AnalizoMetric->mock(
    'calculate',
    sub { die("should not be called again!") }
  );
  $metric->value('MyModule'); # if this does not crash we are OK
}

__PACKAGE__->runtests;
