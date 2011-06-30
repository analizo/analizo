package BatchJobTests;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';
use Test::MockModule;

use Analizo::Batch::Job;

sub constructor : Tests {
  isa_ok(new Analizo::Batch::Job, 'Analizo::Batch::Job');
}

my @EXPOSED_INTERFACE = qw(
  prepare
  execute
  cleanup

  model
  metrics
);

sub exposed_interface : Tests {
  can_ok('Analizo::Batch::Job', @EXPOSED_INTERFACE);
}

sub before_execute : Tests {
  my $job = new Analizo::Batch::Job;
  is($job->model, undef);
  is($job->metrics, undef);
}

sub after_execute : Tests {
  # model and metrics must be set
  my $job = new Analizo::Batch::Job;
  on_dir(
    't/samples/hello_world/c',
    sub {
      $job->execute();
    }
  );
  isa_ok($job->model, 'Analizo::Model');
  isa_ok($job->metrics, 'Analizo::Metrics');
}

sub on_dir {
  my ($dir, $code) = @_;
  my $previous_pwd = `pwd`;
  chomp $previous_pwd;
  chdir $dir;
  &$code();
  chdir $previous_pwd;
}

BatchJobTests->runtests;
