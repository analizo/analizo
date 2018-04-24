package Analizo::Batch::Job::Directories;

use parent qw( Analizo::Batch::Job Class::Accessor::Fast );
use Cwd;

sub new {
  my ($class, $directory) = @_;
  $class->SUPER::new(id => $directory, directory => $directory);
}

__PACKAGE__->mk_accessors(qw(oldcwd));

sub prepare {
  my ($self) = @_;
  $self->oldcwd(getcwd);
  chdir($self->directory);
}

sub cleanup {
  my ($self) = @_;
  chdir($self->oldcwd);
}

1;
