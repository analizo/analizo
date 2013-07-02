package t::Analizo::Test::BDD::Cucumber::Harness;
use strict;
use warnings;
use Moose;
use File::Temp qw( tempdir );

extends 'Test::BDD::Cucumber::Harness::TestBuilder';

use Cwd;
our $top_dir = cwd();
$ENV{LC_ALL} = 'C';
$ENV{PATH} = "$top_dir:$ENV{PATH}";

# Workaround to provide a way to run code before/after every scenario
# TODO: extend the Test::BDD::Cucumber to support defining code
# to execute before and after every scenario, remove this class
# and move the code to the analizo_steps.pl.
#
# Before {
#   print "entering scenario";
# };
#
# After {
#   print "scenario done";
# };

sub scenario { # <= Before
  my ($self, $scenario, $dataset, $longest) = @_;
  $ENV{ANALIZO_CACHE} = tempdir(CLEANUP => 1);
  $self->SUPER::scenario($scenario, $dataset, $longest);
}

sub scenario_done { # <= After
  my ($self, $scenario, $dataset, $longest) = @_;
  $self->SUPER::scenario_done($scenario, $dataset, $longest);
  unlink 'tmp.out';
  unlink 'tmp.err';
  unlink glob('*.tmp');
  chdir $top_dir;
}

1;
