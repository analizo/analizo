package t::Analizo::Test;
use strict;
use warnings;

use base qw( Exporter );
our @EXPORT = qw(
  on_dir
  on_tmpdir
  mock
  tmpdir
  unpack_sample_git_repository
  readfile
);

use Test::MockObject::Extends;
use File::Path qw(remove_tree);

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
  my ($object) = @_;
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

sub on_tmpdir {
  my ($code) = @_;
  my $tmpdir = tmpdir;
  mkdir $tmpdir;
  my $result = on_dir($tmpdir, $code);
  remove_tree $tmpdir;
  return $result;
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
  my ($filename) = @_;
  open INPUT, $filename;
  my @lines = <INPUT>;
  close INPUT;
  chomp @lines;
  return @lines;
}

1;
