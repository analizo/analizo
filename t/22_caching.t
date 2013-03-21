package Analizo::Batch::Output::Caching::Tests;

use strict;
use warnings;
use base qw( Test::Class );
use Test::More;
use Test::Analizo;
use Test::MockModule;

$ENV{'ANALIZO_CACHE'} = tmpdir(); # FIXME is not being removed after

use Analizo::Batch::Job::Directories;

sub model_cache : Tests {
  my $job = new_job();
  $job->execute(); # run first time

  my $result = 'cache used';
  my $AnalizoExtractor = new Test::MockModule('Analizo::Extractor');
  $AnalizoExtractor->mock('process', sub { $result = 'cache not used!' });

  $job->execute();
  is($result, 'cache used');
}

#sub metrics_cache : Tests {
  #ok(0);
#}

sub tree_id : Tests {
  my $job = new_job();
  my $id;
  on_dir(
    't/samples/tree_id',
    sub {
      $id = $job->tree_id('1', '2');
    }
  );
  is($id, 'a17cdf6900c252734b6828385d06787ba64f9620'); # calculated by hand
}

sub new_job {
  my $job = new Analizo::Batch::Job::Directories(id => 'foo', directory => 't/samples/animals/cpp');
  return $job;
}

__PACKAGE__->runtests();
