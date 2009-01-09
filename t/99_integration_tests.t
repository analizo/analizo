package EgyptIntegrationTests;
use base qw(Test::Class);
use Test::More;
use File::Basename;
use File::Spec;

my $sample_dir = dirname(__FILE__) . '/sample';

sub make : Test(startup => 1) {
  my $self = shift;
  system(sprintf('make -s -C %s', $sample_dir));
  my @files = glob("$sample_dir/*.expand");
  ok(scalar(@files) > 0, 'compilation') or $self->BAILOUT('compilation failed!');
}

sub make_clean : Test(shutdown => 1) {
  system(sprintf('make -s -C %s clean', $sample_dir));
  my @files = glob("$sample_dir/*.expand");
  ok(scalar(@files) == 0, 'cleanup');
}

sub get_message {
  my $code = shift;
  my %messages = (
    0 => 'ok',
    1 => 'test name not informed',
    2 => 'no such test',
    3 => 'return status does not match',
    4 => 'stdout does not match',
    5 => 'stderr does not match'
  );
  return $messages{$code} || "unknown error ocurred (exit status = $code)";
}

sub run_tests : Tests {
  my $saved_path = $ENV{'PATH'};

  # modify the path so the tests use the local egypt program instead of the
  # system-wide installed one.
  my $working_dir = File::Spec->rel2abs(dirname(__FILE__) . '/..');
  my $egypt_program = "$working_dir/egypt";
  $ENV{'PATH'} = $working_dir . ':' . $saved_path;
  my @path = split(':', $ENV{'PATH'});

  ok(-f $egypt_program, "egypt program must be found on working directory");
  ok(-x $egypt_program, 'egypt program must be executable');
  ok(File::Spec->file_name_is_absolute( $working_dir ), 'working directory must be an absolute directory name');
  is($path[0], $working_dir, 'working_dir must be added to PATH');

  # run all tests recorded in in the samples directory
  for my $test_file (glob("$sample_dir/tests/*.cmdline")) {
    my $test_name = basename($test_file);
    $test_name =~ s/\.cmdline$//;
    my $status = system("cd $sample_dir && ./run_test $test_name");
    my $outcome = get_message($status >> 8); # see system in perlfunc for the reason of this shift
    ok($status == 0, "integration test [$test_name]: $outcome");
  }

  # restore the path
  $ENV{'PATH'} = $saved_path;
}

EgyptIntegrationTests->runtests;
