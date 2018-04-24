package Test::Analizo::BDD::Cucumber::Extension;
use strict;
use warnings;
use File::Temp qw( tempdir );
use File::Path qw(remove_tree);
use File::Spec;
use parent qw(Test::BDD::Cucumber::Extension);

use Cwd;
our $top_dir = cwd();
$ENV{LC_ALL} = 'C';
$ENV{PATH} = "$top_dir:$ENV{PATH}";

sub pre_scenario {
  my ($self, $scenario, $feature_stash, $scenario_stash) = @_;
  $ENV{ANALIZO_CACHE} = tempdir("analizo-XXXXXXXXXX", CLEANUP => 1, DIR => File::Spec->tmpdir);
}

sub post_scenario {
  my ($self, $scenario, $feature_stash, $scenario_stash, $failed) = @_;
  unlink 'tmp.out';
  unlink 'tmp.err';
  unlink glob('*.tmp');
  remove_tree $ENV{ANALIZO_CACHE};
  chdir $top_dir;
}

1;
