package Analizo::Command::dsm;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Extractor;
use Graph::Writer::DSM;
use File::Basename;

=head1 NAME

Analizo::Command::dsm - draw the design structure matrix from call graph

=head1 USAGE

  analizo dsm [OPTIONS] <input> [<input> [<input> ...]]

=cut

sub usage_desc { "%c dsm %o <input> [<input> [<input> ...]]" }

sub opt_spec {
  return (
    [ 'extractor=s', 'wich extractor method use to analise source code' ],
    [ 'output|o=s',  'output file name', { default => 'dsm.png' } ],
    [ 'exclude|x=s', 'exclude <dirs> (a colon-separated list of directories) from the analysis' ],
  );
}

sub validate {
  my ($self, $opt, $args) = @_;
  $self->usage_error("No input files!") unless @$args;
  my @unreadable = grep { ! -r $_ || ! -e $_ } @$args;
  if (@unreadable) {
    foreach my $file (@unreadable) {
      $self->usage_error("$file is not readable");
    }
  }
  if ($opt->output && ! -w dirname($opt->output)) {
    $self->usage_error("Output is not writable!");
  }
}

sub execute {
  my ($self, $opt, $args) = @_;
  my $extractor = Analizo::Extractor->load($opt->extractor);
  if ($opt->exclude) {
    my @excluded_directories = split(':', $opt->exclude);
    $extractor->exclude(@excluded_directories);
  }
  my $model = $extractor->model;
  $extractor->process(@$args);
  my $graph = $model->graph();
  my $wr = Graph::Writer::DSM->new();
  $wr->write_graph($graph, $opt->output);
}

=head1 DESCRIPTION

analizo dsm reads the dependency information from one or more source code
directories passed as arguments, and produces as output the design structure
matrix from the dependencies between files of the software.

analizo dsm is part of the analizo suite.

=head1 OPTIONS

=over

=item --extractor <extractor>

Define wich extractor method use to analise source code. Default is Doxyparse.

=item --output <file>, -o <file>

Writes output to <file>. Default is "dsm.png".

=item --exclude <dirs>, -x <dirs>

Exclude <I<dirs>> (a colon-separated list of directories) from the analysis.
This is useful, for example, when you want to focus on production code and
exclude test code from the analysis. You could do that by passing something
like pass B<--exclude test>.

=back

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
