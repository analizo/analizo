package t::Analizo::Batch::Output::CSV;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More 'no_plan';
use t::Analizo::Test;

use Analizo::Batch::Output::CSV;
use Analizo::Batch::Output::yaml2csv;
use Analizo::Batch::Job::Directories;

my $TMPDIR = tmpdir();
my $TMPFILE = "$TMPDIR/output.csv";

sub setup : Tests(setup) {
  system("mkdir -p $TMPDIR");
  my $output = __create();

  my $job1 = new Analizo::Batch::Job::Directories('t/samples/animals/cpp');
  $job1->execute();
  $output->push($job1);

  my $job2 = new Analizo::Batch::Job::Directories('t/samples/animals/java');
  $job2->execute();
  $output->push($job2);

  $output->file($TMPFILE);
  $output->flush();

  my @lines = readfile $TMPFILE;
}

sub teardown : Tests(teardown) {
  system("rm -rf $TMPDIR");
}

sub constructor : Tests {
  my $output = __create();
  isa_ok($output, 'Analizo::Batch::Output::CSV');

  my $yaml2csv = Analizo::Batch::Output::yaml2csv->new("../../../samples/animals/java"); 
  isnt($yaml2csv, undef);
  can_ok($yaml2csv, 'extract_lines');
  can_ok($yaml2csv, 'extract_labels');
  can_ok($yaml2csv, 'write_csv');
}

sub extract_labels : Tests {
  my $yaml2csv = Analizo::Batch::Output::yaml2csv->new("t/samples/animals/java"); 
  isnt($yaml2csv, undef);
  is($yaml2csv->extract_labels(),18); 
  my @labels = $yaml2csv->extract_labels();
  is($labels[0],"_filename"); 
  is($labels[17],"sc");   
}

sub extract_lines_cpp : Tests {
  my $yaml2csv = Analizo::Batch::Output::yaml2csv->new("t/samples/animals/cpp"); 
  isnt($yaml2csv, undef);
  my @array_of_values = $yaml2csv->extract_lines(extract_labels());
  isnt(@array_of_values, undef);
  is($array_of_values[0], '- animal.h ');    
}

sub extract_lines_java : Tests {
  my $yaml2csv = Analizo::Batch::Output::yaml2csv->new("t/samples/animals/java"); 
  isnt($yaml2csv, undef);
  my @array_of_values = $yaml2csv->extract_lines(extract_labels());
  isnt(@array_of_values, undef);
  is($array_of_values[0], '- Animal.java ');    
} 

sub write_csv_cpp : Tests {
  my $yaml2csv = Analizo::Batch::Output::yaml2csv->new("t/samples/animals/cpp"); 
  $yaml2csv->write_csv(); 
  isnt($yaml2csv, undef);  
  open(my $file_cpp, "<", $yaml2csv->{job_directory} . "-details.csv") || die "Cannot open ".$yaml2csv->{job_directory} . "-details.csv\n".$!;
  is(-e $file_cpp, 1);
}


sub write_csv_java : Tests {
  my $yaml2csv = Analizo::Batch::Output::yaml2csv->new("t/samples/animals/java");
  $yaml2csv->write_csv(); 
  isnt($yaml2csv, undef);  
  open(my $file_java, "<", $yaml2csv->{job_directory} . "-details.csv") || die "Cannot open ".$yaml2csv->{job_directory} . "-details.csv\n".$!;
  is(-e $file_java, 1);
}

sub __create {
  my @args = @_;
  return new Analizo::Batch::Output::CSV(@args);
}


__PACKAGE__->runtests;

1;
