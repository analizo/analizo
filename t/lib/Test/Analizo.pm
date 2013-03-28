package Test::Analizo;
use strict;
use warnings;

use base qw( Exporter );
our @EXPORT = qw(
  on_dir
  mock
  tmpdir
  unpack_sample_git_repository
  readfile
);

use Test::MockObject::Extends;

sub on_dir {
  my ($dir, $code) = @_;
  my $previous_pwd = `pwd`;
  chomp $previous_pwd;
  chdir $dir;
  if (wantarray()) {
    my @list = &$code();
    chdir $previous_pwd;
    return @list;
  }
  my $result = &$code();
  chdir $previous_pwd;
  return $result;
}

sub mock {
  my $object = shift;
  new Test::MockObject::Extends($object);
}

sub tmpdir {
  my ($package, $filename, $line) = caller;
  return tmpdir_for($filename);
}

use Cwd 'abs_path';
sub tmpdir_for {
  my ($filename) = @_;
  $filename = abs_path($filename);
  return $filename . '.tmpdir';
}

sub unpack_sample_git_repository {
  my ($code, @repos) = @_;
  if (!@repos) {
    @repos = ('evolution');
  }
  my ($package, $filename, $line) = caller;
  my $tmpdir = tmpdir_for($filename);
  system("mkdir -p $tmpdir");
  for my $repo (@repos) {
    system("tar xzf t/samples/$repo.tar.gz -C $tmpdir");
  }
  &$code();
  system("rm -rf $tmpdir");
}

sub readfile {
  my $filename = shift;
  open INPUT, $filename;
  my @lines = <INPUT>;
  close INPUT;
  chomp @lines;
  return @lines;
}

1;
