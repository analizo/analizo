package Test::Analizo::BDD::Cucumber::Extension;
use strict;
use warnings;
use File::Temp qw( tempdir );

use Moo;
extends 'Test::BDD::Cucumber::Extension';

use Cwd;
our $top_dir = cwd();
$ENV{LC_ALL} = 'C';
$ENV{PATH} = "$top_dir:$ENV{PATH}";

sub pre_scenario {
  my ($self, $scenario, $feature_stash, $scenario_stash) = @_;
  $ENV{ANALIZO_CACHE} = tempdir(CLEANUP => 1);
}

sub post_scenario {
  my ($self, $scenario, $feature_stash, $scenario_stash, $failed) = @_;
  unlink 'tmp.out';
  unlink 'tmp.err';
  unlink glob('*.tmp');
  chdir $top_dir;
}

1;
