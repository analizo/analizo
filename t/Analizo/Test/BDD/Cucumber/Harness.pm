package t::Analizo::Test::BDD::Cucumber::Harness;
use strict;
use warnings;
use Moose;
 
extends 'Test::BDD::Cucumber::Harness::TestBuilder';

use Cwd;
our $top_dir = cwd();

# Workaround to provide a way to run code after every scenario.
# TODO: extend the Test::BDD::Cucumber to support defining code
# to execute before and after every scenario and remove this class.
#
# Before {
#   print "entering scenario";
# };
#
# After {
#   print "scenario done";
# };

sub scenario_done {
  my ($self, $scenario, $dataset, $longest) = @_;
  $self->SUPER::scenario_done($scenario, $dataset, $longest);
  unlink 'tmp.out';
  unlink 'tmp.err';
  unlink glob('*.tmp');
  chdir $top_dir;
}

1;
