package Test::Analizo;
use strict;
use warnings;

use base qw( Exporter );
our @EXPORT = qw(
  on_dir
  mock
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

1;
