package Analizo::VCS;
use strict;
use warnings;
use Class::Accessor::Fast qw(antlers);
use Analizo::VCS::Driver;

has driver => (is => 'ro');

sub new {
  my ($class, $driver_name) = @_;
  die unless $driver_name;
  my @available_drivers = Analizo::VCS::Driver->available_drivers;
  unless (grep { $_ eq $driver_name } @available_drivers) {
    local $" = "\n";
    die "E: Unavailable driver!\n\n" .
        "Available drivers:\n" .
        "@available_drivers\n\n";
  }
  my $DRIVER_CLASS = "Analizo::VCS::Driver::$driver_name";
  eval "use $DRIVER_CLASS;";
  $class->SUPER::new({ driver => $DRIVER_CLASS->new });
}

sub _repository_exists {
  my ($output) = @_;
  -e $output && -d $output;
}

sub fetch {
  my ($self, $url, $output) = @_;
  $self->driver->url($url);
  $self->driver->output($output) if $output;
  if (_repository_exists($self->driver->output)) {
    warn sprintf("E: It seens that the repository '%s' already been fetched!\n", $self->driver->output);
    return 0;
  }
  print "I: Fetching...";
  return $self->driver->fetch;
}

1;
