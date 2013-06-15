package t::Analizo::Command::metricsbatch;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan';
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::metricsbatch'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricsbatch');
  isa_ok($cmd, 'Analizo::Command::metricsbatch');
}

sub construct_through_alias : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metrics-batch');
  isa_ok($cmd, 'Analizo::Command::metricsbatch');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricsbatch');
  isa_ok($cmd, 'Analizo::Command');
}

__PACKAGE__->runtests;
