package t::Analizo::Batch::Runner::Parallel;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;

use Analizo::Batch::Runner::Parallel;

use Analizo::Batch::Runner::Sequential;
use Analizo::Batch::Output;
use Analizo::Batch::Directories;

sub constuctor : Tests {
  my $obj = __create();
  isa_ok($obj, 'Analizo::Batch::Runner');
  isa_ok($obj, 'Analizo::Batch::Runner::Parallel');
}

sub number_of_parallel_processes : Tests {
  my $default = __create();
  is($default->parallelism, 2);

  my $four = __create(4);
  is($four->parallelism, 4);
}

sub __create {
  my @args = @_;
  Analizo::Batch::Runner::Parallel->new(@args);
}

__PACKAGE__->runtests;
