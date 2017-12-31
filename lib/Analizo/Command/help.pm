package Analizo::Command::help;
use parent qw(App::Cmd::Command::help Analizo::Command);
use strict;
use warnings;

#ABSTRACT: displays the help

=head1 NAME

analizo-help - displays the help

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
  my $command_name = $args->[0];
  if ($self->app->global_options->version) {
    printf("%s\n", $self->version_information);
    exit 0;
  }
  elsif ($command_name) {
    (my $package_name = $command_name) =~ s/-/_/g;
    $self->show_manpage("Analizo::Command::$package_name", $command_name);
    exit 0;
  }
  elsif ($self->app->global_options->help || (@ARGV && $ARGV[0] eq '--help')) {
    $self->show_manpage('Analizo', 'analizo');
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
