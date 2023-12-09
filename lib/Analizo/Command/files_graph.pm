package Analizo::Command::files_graph;
use Analizo -command;
use parent qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Extractor;
use Graph::Writer::Dot '2.09';
use File::Basename;

# ABSTRACT: dependency graph generator among files

=head1 NAME

analizo-files-graph - dependency graph generator among files

=head1 USAGE

  analizo files-graph [OPTIONS] <input> [<input> [<input> ...]]

=cut

sub usage_desc { "%c files-graph %o <input> [<input> [<input> ...]]" }

sub command_names { qw/files-graph/ }

sub opt_spec {
  return (
    [ 'extractor=s', 'which extractor method use to parse the source code' ],
    [ 'output|o=s',  'output file name' ],
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
    $self->usage_error("No such file or directory");
  }
}

sub execute {
  my ($self, $opt, $args) = @_;
  my $extractor = Analizo::Extractor->load($opt->extractor);
  $extractor->process(@$args);
  my $graph = $extractor->model->files_graph;
  if ($opt->output) {
    open STDOUT, '>', $opt->output or die "$!";
  }
  my $stdout = \*STDOUT;
  my $graph_writer = Graph::Writer::Dot->new;
  $graph_writer->write_graph($graph, $stdout);
  close STDOUT;
}

=head1 DESCRIPTION

analizo files-graph reads the dependency information from one or more source code
directories passed as arguments, and produces as output the graph of
dependencies between the files of the software in the graphviz(1) format.

analizo files-graph is part of the analizo suite and was implemented to
represent the old analizo dsm output tool in a textual format, as the dsm tool
is going to be removed from analizo suite. The dependency graph includes
relationships among files including function calls, inheritances and attribute
use.

analizo files-graph is part of the analizo suite.

=head1 REQUIRED ARGUMENTS

=over

=item <input>...

The input directories (or files) with source code to be processed.

Although you can pass individual files as input, this tool is more useful if
you pass entire source directories.

=back

=head1 OPTIONS

=over

=item --output <file>, -o <file>

Use a file as output

=back

=head1 VIEWING THE GRAPH

See B<analizo-graph(1)>.

=head1 READING THE GRAPH

See B<analizo-graph(1)>.

=head1 SEE ALSO

B<dotty(1)>, B<dot(1)>, B<neato(1)>, B<analizo(1)>

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
