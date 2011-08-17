package BatchOutputTests;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More 'no_plan';
use Test::Analizo;

use Analizo::Batch::Output;

sub constructor : Tests {
  isa_ok(__create(), 'Analizo::Batch::Output');
}

sub exposed_interface : Tests {
  can_ok('Analizo::Batch::Output', qw(requires_metrics push initialize flush));
}

sub not_require_metrics_by_default : Tests {
  my $output = __create();
  is($output->requires_metrics, 0);
}

sub should_write_to_output_file : Tests {
  my $output = mock(__create());
  my $delegated = undef;
  $output->mock('write_data', sub { my ($that, $fh) = @_; $delegated = (ref($fh) eq 'GLOB'); });

  $output->file('t/tmp/output.tmp');
  $output->flush();
  ok(-e 't/tmp/output.tmp', 'output must be written to file');
  ok($delegated, 'must delegate actualy writing to subclasses');
}

sub must_write_to_stdout_when_no_file_is_given : Tests {
  my $output = mock(__create());
  my $write_data_called = 0;
  $output->mock('write_data', sub { if ($_[1] eq *STDOUT) { $write_data_called++ }});
  $output->flush();
  ok($write_data_called == 1);
}

sub __create {
  new Analizo::Batch::Output;
}

BatchOutputTests->runtests;
