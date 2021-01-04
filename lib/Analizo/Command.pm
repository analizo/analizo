package Analizo::Command;
use App::Cmd::Setup -command;
use strict;
use warnings;
use Class::Inspector;
use Env::Path qw( PATH );
use File::Temp qw( tmpnam );

=head1 NAME

Analizo::Command - global options for tools

=head1 DESCRIPTION

Following the instructions from the L<App::Cmd::Tutorial> we create this module
to be a superclass of every analizo tool, in that way we can have global
options to every analizo tool:

  analizo <tool> --help
  analizo <tool> --usage

Any analizo tool should implement B<validate()>, method which is called by
B<validate_args()> implemented here. See L<App::Cmd::Command> for details about
B<validate_args()>.

=cut

sub validate_args {
  my ($self, $opt, $args) = @_;
  if ($self->app->global_options->version) {
    $self->usage_error("Invalid option: --version");
  }
  elsif ($self->app->global_options->usage) {
    print $self->app->usage, "\n", $self->usage;
    exit 0;
  }
  $self->validate($opt, $args);
}

sub version_information {
  my ($self) = @_;
  sprintf("%s version %s", $self->app->arg0, $Analizo::VERSION);
}

sub show_manpage {
  my ($self, $package, $command_name) = @_;
  my $version_information = $self->version_information;
  my $file = Class::Inspector->resolved_filename($package);
  if (scalar PATH->Whence('man')) {
    my $pod2man = "pod2man --name='analizo-$command_name' --release='$version_information' --center='Analizo documentation'";
    if ($^O eq 'freebsd') {
      my $tmpfile = tmpnam();
      exec("$pod2man '$file' > $tmpfile && man $tmpfile && rm -f $tmpfile");
    }
    else {
      exec("$pod2man '$file' | man -l -");
    }
  }
  elsif (scalar PATH->Whence('less')) {
    exec("pod2text '$file' | less");
  }
  elsif (scalar PATH->Whence('more')) {
    exec("pod2text '$file' | more");
  }
  else {
    exec("pod2text '$file'");
  }
}

1;

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut
