package Analizo::Command::dsm;
use Analizo -command;
use parent qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Extractor;
use Graph::Writer::DSM;
use Graph::Writer::DSM::HTML;
use File::Basename;
use Cwd 'abs_path';

# ABSTRACT: draw the design structure matrix from call graph

=head1 NAME

analizo-dsm - draw the design structure matrix from call graph

=head1 USAGE

  analizo dsm [OPTIONS] <input> [<input> [<input> ...]]

=cut

sub usage_desc { "%c dsm %o <input> [<input> [<input> ...]]" }

sub opt_spec {
  return (
    [ 'extractor=s', 'wich extractor method use to analise source code' ],
    [ 'format|f=s',  'choice of output format to use', { default => 'png' } ],
    [ 'output|o=s',  'output file name' ],
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
  if ($opt->format ne 'png' && $opt->format ne 'html') {
    $self->usage_error(sprintf("%s is not a valid output format.", $opt->format));
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
  my $graph_writer = undef;
  if ($opt->format eq 'png') {
    $graph_writer = Graph::Writer::DSM->new();
  }
  elsif ($opt->format eq 'html') {
    my $name = join(', ', map { basename(abs_path($_)) } @$args);
    $graph_writer = Graph::Writer::DSM::HTML->new(
      title => 'Design Structure matrix for ' . $name
    );
  }
  my $output = $opt->output || sprintf("dsm.%s", $opt->format);
  $graph_writer->write_graph($graph, $output);
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

=item --format <format>, -f <format>

Choice of output format to use. Supported formats are B<png> (the default; good
for very large code bases), and B<html> (good for small-medium code bases).

=item --output <file>, -o <file>

Writes output to <file>. Default is "dsm.<format>".

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
