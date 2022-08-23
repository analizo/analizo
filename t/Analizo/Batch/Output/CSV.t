package t::Analizo::Batch::Output::CSV;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;

use Analizo::Batch::Output::CSV;
use Analizo::Batch::Job::Directories;

my $TMPDIR = tmpdir();
my $TMPFILE = "$TMPDIR/output.csv";

sub setup : Tests(setup) {
  system("mkdir", "-p", $TMPDIR);
}

sub teardown : Tests(teardown) {
  system("rm", "-rf", $TMPDIR);
}

sub constructor : Tests {
  my $output = __create();
  isa_ok($output, 'Analizo::Batch::Output::CSV');
}

sub writing_data : Tests {
  my $output = __create();

  my $job1 = Analizo::Batch::Job::Directories->new('t/samples/animals/cpp');
  $job1->execute();
  $output->push($job1);

  my $job2 = Analizo::Batch::Job::Directories->new('t/samples/animals/java');
  $job2->execute();
  $output->push($job2);

  $output->file($TMPFILE);
  $output->flush();

  my @lines = readfile $TMPFILE;

  ok(scalar(@lines) == 3, 'must write data to output file');

  ok($lines[0] =~ /^\w+(,\w+)+$/, 'first line must contain column names');

  my $empty_lines = grep { /^\s*$/ } @lines;
  ok($empty_lines == 0, 'CSV output must not contain empty lines');
}

sub job_metadata : Tests {
  my $job = mock(Analizo::Batch::Job::Directories->new('t/samples/animals/cpp'));
  $job->mock('metadata', sub { [ ['data1', 88], [ 'data2', 77 ] ] });
  $job->mock('id', sub { 99 });
  $job->execute();

  my $output = __create();
  $output->file($TMPFILE);
  $output->push($job);
  $output->flush();

  my @lines = readfile($TMPFILE);

  ok($lines[0] =~ /^id,data1,data2/, 'must list metadata fields');
  ok($lines[1] =~ /^99,88,77/, 'must include metadata values');
}

sub must_write_list_data_as_string : Tests {
  my $job = mock(Analizo::Batch::Job::Directories->new('t/samples/animals/cpp'));
  $job->execute();
  $job->mock(
    'metadata',
    sub { [['values', ['onething','otherthing']],] }
  );

  my $output = __create();
  $output->file($TMPFILE);
  $output->push($job);
  $output->flush();

  my @lines = readfile $TMPFILE;
  like($lines[1], qr/,"onething;otherthing",/);

}

sub must_write_hash_data_as_string : Tests {
  my $job = mock(Analizo::Batch::Job::Directories->new('t/samples/animals/cpp'));
  $job->execute();
  $job->mock(
    'metadata',
    sub { [['data', { 'key1' => 'value1', 'key2' => 'value2'}]]}
  );

  my $output = __create();
  $output->file($TMPFILE);
  $output->push($job);
  $output->flush();

  my @lines = readfile($TMPFILE);
  like($lines[1], qr/,"key1:value1;key2:value2",/);
}

sub must_return_short_names_of_metrics : Tests {
	my $output = __create();
	my @short_names = ();

	@short_names = $output->_extract_short_names_of_metrics();

	ok($short_names[0] eq "acc", "must list acc metric name");
	ok($short_names[1] eq "accm", "must list accm metric name");
	ok($short_names[2] eq "amloc", "must list amloc metric name");
	ok($short_names[3] eq "anpm", "must list anpm metric name");
}

sub __create {
  my @args = @_;
  my $output = mock(Analizo::Batch::Output::CSV->new(@args));
  $output->mock('write_details', sub { });
  return $output;
}

__PACKAGE__->runtests;

1;
