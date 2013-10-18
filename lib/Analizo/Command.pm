package Analizo::Command;
use App::Cmd::Setup -command;
use strict;
use warnings;
use Class::Inspector;

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
  elsif ($self->app->global_options->help) {
    my $package = ref $self;
    $self->show_manpage($package, $self->command_names);
    exit 0;
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
  exec("pod2man --name='analizo-$command_name' --release='$version_information' --center='Analizo documentation' '$file' | man -l -");
}

1;

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut
