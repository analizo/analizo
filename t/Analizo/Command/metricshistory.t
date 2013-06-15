package t::Analizo::Command::metricshistory;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan';
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::metricshistory'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricshistory');
  isa_ok($cmd, 'Analizo::Command::metricshistory');
}

sub construct_through_alias : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metrics-history');
  isa_ok($cmd, 'Analizo::Command::metricshistory');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricshistory');
  isa_ok($cmd, 'Analizo::Command');
}

sub output_driver : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricshistory');
  cmp_ok($cmd->output_driver('csv'), 'eq', 'Analizo::Batch::Output::CSV');
  cmp_ok($cmd->output_driver('db'), 'eq', 'Analizo::Batch::Output::DB');
}

sub nil_for_unavaiable_output_driver : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricshistory');
  ok(! $cmd->output_driver('something'));
}

sub load_output_driver : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metricshistory');
  isa_ok($cmd->output_driver('csv'), 'Analizo::Batch::Output::CSV');
}

__PACKAGE__->runtests;
