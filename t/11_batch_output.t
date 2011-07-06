package BatchOutputTests;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More 'no_plan';
use Analizo::Batch::Output;

sub constructor : Tests {
  isa_ok(__create(), 'Analizo::Batch::Output');
}

sub exposed_interface : Tests {
  can_ok('Analizo::Batch::Output', qw(requires_metrics push));
}

sub not_require_metrics_by_default : Tests {
  my $output = __create();
  is($output->requires_metrics, 0);
}

use Test::MockObject::Extends;

sub should_write_to_output_file : Tests {
  my $output = new Test::MockObject::Extends(__create());
  my $delegated = undef;
  $output->mock('write_data', sub { my ($that, $fh) = @_; $delegated = (ref($fh) eq 'GLOB'); });

  $output->file('t/tmp/output.tmp');
  $output->flush();
  ok(-e 't/tmp/output.tmp', 'output must be written to file');
  ok($delegated, 'must delegate actualy writing to subclasses');
}

sub __create {
  new Analizo::Batch::Output;
}

BatchOutputTests->runtests;
