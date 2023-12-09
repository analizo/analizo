package t::Analizo::Batch::Directories;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;

use Test::Analizo;

use Analizo::Batch::Directories;

sub expose_list_of_dirs : Tests {
  can_ok('Analizo::Batch::Directories', 'directories');
}

sub create_with_no_arguments : Tests {
  my $batch = __create_batch();
  my @actual = sort(@{$batch->directories});
  is_deeply(\@actual, ['c', 'cpp', 'csharp', 'java', 'python']);
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
  on_dir('t/samples/hello_world', sub { Analizo::Batch::Directories->new(@args) });
}

__PACKAGE__->runtests;

1;
