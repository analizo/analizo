package Analizo::Command::help;
use base qw(App::Cmd::Command::help Analizo::Command);
use strict;
use warnings;

=head1 NAME

Analizo::Command::help - displays the help

=head1 DESCRIPTION

This module inherits from the L<App::Cmd::Command::help> just to provide a way
to displays the version, help and usage of the `analizo` script. For example:

  analizo --version
  analizo --help
  analizo --usage

As documented in L<App::Cmd#default_command> the `help` is the default command,
it is called when the script `analizo` is executed without inform any command.

=cut

sub execute {
  my ($self, $opt, $args) = @_;
  if ($self->app->global_options->version) {
    printf("%s\n", $self->version_information);
    exit 0;
  }
  elsif ($self->app->global_options->help) {
    $self->show_manpage('Analizo');
    exit 0;
  }
  elsif ($self->app->global_options->usage) {
    print $self->app->usage;
    exit 0;
  }
  $self->SUPER::execute($opt, $args);
}

1;

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut
