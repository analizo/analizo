package BatchOutputTests;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';
use Analizo::Batch::Output;

sub constructor : Tests {
  isa_ok(new Analizo::Batch::Output, 'Analizo::Batch::Output');
}

sub exposed_interface : Tests {
  can_ok('Analizo::Batch::Output', 'requires_metrics');
}

sub not_require_metrics_by_default : Tests {
  my $output = new Analizo::Batch::Output;
  is($output->requires_metrics, 0);
}

BatchOutputTests->runtests;
