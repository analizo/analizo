package Analizo::Batch::Tests;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';
use Analizo::Test;
use Analizo::Batch;
use Analizo::Batch::Job;

sub constructor: Tests {
  isa_ok(new Analizo::Batch, 'Analizo::Batch');
}

sub next : Tests {
  can_ok('Analizo::Batch', 'next');

  my $batch = new Analizo::Batch;
  is($batch->next, undef);
}

sub count : Tests {
  can_ok("Analizo::Batch", 'count');
}

sub pass_filters_forward : Tests {
  my $batch = mock(new Analizo::Batch);
  my $job = new Analizo::Batch::Job;
  $batch->mock('fetch_next', sub { $job });
  my $filter = new Analizo::LanguageFilter('c');
  $batch->filters($filter);
  $batch->next();
  is_deeply($job->filters, [$filter], 'must pass filters into job');
}

__PACKAGE__->runtests;
