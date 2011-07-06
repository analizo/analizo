package Analizo::Batch::Output::CSV::Test;
use strict;
use warnings;
use base qw(Test::Analizo::Class);
use Test::More 'no_plan';

use Analizo::Batch::Output::CSV;
use Analizo::Batch::Job::Directories;

sub constructor : Tests {
  my $output = __create();
  isa_ok($output, 'Analizo::Batch::Output::CSV');
}

sub writing_data : Tests {
  my $output = __create();

  my $job1 = new Analizo::Batch::Job::Directories('t/samples/animals/cpp');
  $job1->execute();
  $output->push($job1);

  my $job2 = new Analizo::Batch::Job::Directories('t/samples/animals/java');
  $job2->execute();
  $output->push($job2);

  $output->file('t/tmp/output.csv');
  $output->flush();

  open IN, 't/tmp/output.csv';
  my @lines = <IN>;
  close IN;

  ok($#lines == 2, 'must write data to output file');

  ok($lines[0] =~ /^\w+(,\w+)+$/, 'first line must contain column names');

  my $empty_lines = grep { /^\s*$/ } @lines;
  ok($empty_lines == 0, 'CSV output must not contain empty lines');
}

sub __create {
  my @args = @_;
  return new Analizo::Batch::Output::CSV(@args);
}

__PACKAGE__->runtests;

1;
