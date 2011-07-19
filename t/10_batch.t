package BatchTests;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';
use Analizo::Batch;

sub constructor: Tests {
  isa_ok(new Analizo::Batch, 'Analizo::Batch');
}

sub next : Tests {
  can_ok('Analizo::Batch', 'next');

  my $batch = new Analizo::Batch;
  is($batch->next, undef);
}


BatchTests->runtests;
