package Analizo::Command::evolution_matrix;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use Analizo::EvolutionMatrix;
use Analizo::EvolutionMatrix::Cell;
use YAML::Tiny;
use Mojo::Template;
use File::Basename;

# ABSTRACT: generates an evolution matrix from analizo .yml metric files

=head1 NAME

analizo evolution-matrix - generates an evolution matrix from analizo .yml metric files

=head1 USAGE

  analizo evolution-matrix [OPTIONS] <ymlfile> [<ymlfile> [<ymlfile>...]]

=cut

sub usage_desc { "%c evolution-matrix %o <ymlfile> [<ymlfile> [<ymlfile>...]]" }

sub command_names { qw/evolution-matrix/ }

sub opt_spec {
  return (
    [ 'width|w=s',  'metric name used as the width of the matrix cells', { default => 'nom' } ],
    [ 'height|h=s', 'metric name used as the height of the matrix cells', { default => 'loc' } ],
    [ 'name|n=s',   'name of the project being analysed', { default => 'Unamed project' } ],
    [ 'output|o=s', 'output file name' ],
  );
}

sub validate {
  my ($self, $opt, $args) = @_;
  $self->usage_error("No input files!") unless @$args;
  if ($opt->output && ! -w dirname($opt->output)) {
    $self->usage_error("Output is not writable!");
  }
}

sub execute {
  my ($self, $opt, $args) = @_;
  my $matrix = Analizo::EvolutionMatrix->new({
    cell_width  => $opt->width,
    cell_height => $opt->height,
    name        => $opt->name,
  });
  foreach my $yml (@$args) {
    (my $version = $yml) =~ s/^.*-(.*)\.yml$/$1/;
    my $stream = YAML::Tiny->read($yml)
      or die YAML::Tiny->errstr;
    print STDERR "I: Processing $yml ...\n";
    if (@{ $stream } > 0) {
      foreach my $doc (@{ $stream }) {
        if ($doc->{_module}) {
          $matrix->put($doc->{_module}, $version, $doc);
        }
      }
    } else {
      print STDERR "W: $yml seems to be empty\n";
    }
  }
  if ($matrix->is_empty) {
    print STDERR "E: no data found! Do the input files contain module data?\n";
  }
  else {
    if ($opt->output) {
      open STDOUT, '>', $opt->output or die "$!\n";
    }
    my $template = Mojo::Template->new;
    print STDOUT $template->render_file('templates/analizo-evolution-matrix.html.ep', $matrix);
    close STDOUT;
  }
}

=head1 DESCRIPTION

B<analizo evolution-matrix> generates evolution matrices from project metrics
data.

The evolution matrix is a techinique for software evolution analysis
introduced in
I<Lanza, M. 2001. The evolution matrix: recovering software evolution using
software visualization techniques. In Proceedings of the 4th international
Workshop on Principles of Software Evolution (Vienna, Austria, September 10 -
11, 2001). IWPSE '01. ACM, New York, NY, 37-42. DOI=
http://doi.acm.org/10.1145/602461.602467>. Please refer to that paper for a
very nice explanation of the uses for an evolution matrix.

B<analizo evolution-matrix> will process the YML files passed in the command
line and generate an evolution matrix. To do that we assume that the YML
files are name as project-name-I<X.Y.X>.yml, where I<X.Y.Z> represents the
version numbers of different versions of the same project.

The output is HTML code corresponding to the evolution matrix of the #
project, considering all the versions passed in the command line. By default
the output is trown in the standard output, but once can override that with
the B<-o> option.

=head1 OPTIONS

=over

=item --width <metric>, -w <metric>

Uses <metric> as width of the matrix cells. Available metrics can be
checked with `analizo metrics --list`, in the "Module metrics" section.

=item --height <metric>, -h <metric>

Uses <metric> as height of the matrix cells. Available metrics can be
checked with `analizo metrics --list`, in the "Module metrics" section.

=item --name <name>, -n <name>

Sets the name of the project being analysed. Used in the generated report.

=item --output <file>, -o <file>

Writes output to <file> instead of to standard output.

=back

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
