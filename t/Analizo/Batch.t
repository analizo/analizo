package t::Analizo::Batch;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More;
use Test::Analizo;
use Analizo::Batch;
use Analizo::Batch::Job;

sub constructor: Tests {
  isa_ok(Analizo::Batch->new, 'Analizo::Batch');
}

sub next : Tests {
  can_ok('Analizo::Batch', 'next');

  my $batch = Analizo::Batch->new;
  is($batch->next, undef);
}

sub count : Tests {
  can_ok("Analizo::Batch", 'count');
}

sub pass_filters_forward : Tests {
  my $batch = mock(Analizo::Batch->new);
  my $job = Analizo::Batch::Job->new;
  $batch->mock('fetch_next', sub { $job });
  my $filter = Analizo::LanguageFilter->new('c');
  $batch->filters($filter);
  $batch->next();
  is_deeply($job->filters, [$filter], 'must pass filters into job');
}

__PACKAGE__->runtests;
