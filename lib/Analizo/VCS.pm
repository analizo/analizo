package Analizo::VCS;
use Moo;
use Analizo::VCS::Driver;

has driver => (is => 'ro');

sub BUILDARGS {
  my ($class, $driver_name) = @_;
  my @available_drivers = Analizo::VCS::Driver->available_drivers;
  unless (grep { $_ eq $driver_name } @available_drivers) {
    die "Unavailable driver: $driver_name\n" .
        "Available drivers are: " .
        "@available_drivers\n";
  }
  my $DRIVER_CLASS = "Analizo::VCS::Driver::$driver_name";
  eval "use $DRIVER_CLASS;";
  return { driver => $DRIVER_CLASS->new };
}

sub download {
  my ($self, $url) = @_;
  $self->driver->url($url);
  if ($self->driver->repository_exists) {
    warn "It seens that ", $self->driver->url, " already been downloaded before!\n",
         "Found local directory: ", $self->driver->url_sha1, "\n";
    return 0;
  }
  $self->driver->download;
}

1;
