use strict;
use warnings;
use Test::More;
use Test::BDD::Cucumber::StepFile;
use Method::Signatures;
use Cwd;
use File::Slurp;

our $top_dir = cwd();
our $saved_path = $ENV{PATH};

$ENV{LC_ALL} = 'C';
$ENV{PATH} = "$top_dir:$ENV{PATH}";

our $exit_status;
our $stdout;
our $stderr;

sub run {
  my ($command) = @_;
  $exit_status = system "($command) >tmp.out 2>tmp.err";
  $stdout = read_file('tmp.out');
  $stderr = read_file('tmp.err');
}

When qr/^I run "([^\"]*)"$/, func($c) {
  run $1;
};

Then qr/^the output must match "([^\"]*)"$/, func($c) {
  like($stdout, qr/$1/);
};

Then qr/^the exit status must be (\d+)$/, func($c) {
  cmp_ok($exit_status, '==', $1);
};

Then qr/^the exit status must not be (\d+)$/, func($c) {
  cmp_ok($exit_status, '!=', $1);
};
