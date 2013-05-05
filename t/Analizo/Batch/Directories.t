package t::Analizo::Batch::Directories;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More 'no_plan';

use t::Analizo::Test;

use Analizo::Batch::Directories;

sub expose_list_of_dirs : Tests {
  can_ok('Analizo::Batch::Directories', 'directories');
}

sub create_with_no_arguments : Tests {
  my $batch = __create_batch();
  my @actual = sort(@{$batch->directories});
  is_deeply(\@actual, ['c', 'cpp', 'java']);
}

sub create_with_arguments : Tests {
  my $batch = __create_batch(qw(c cpp));
  is_deeply($batch->directories, ['c', 'cpp']);
}

sub create_with_bad_arguments : Tests {
  my $batch = __create_batch(qw(c fortran));
  is_deeply(['c'], $batch->directories);
}

sub deliver_jobs : Tests {
  my $batch = __create_batch(qw(c cpp));
  my $job = $batch->next();
  is($job->directory, 'c');
  $job = $batch->next();
  is($job->directory, 'cpp');
  is(undef, $batch->next());
}

sub count : Tests {
  my $batch = __create_batch(qw(c cpp));
  is($batch->count, 2);
}

sub __create_batch {
  my @args = @_;
  on_dir('t/samples/hello_world', sub { new Analizo::Batch::Directories(@args) });
}

__PACKAGE__->runtests;

1;
