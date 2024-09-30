package Analizo::Command::graph;
use Analizo -command;
use parent qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Extractor;
use Graph::Writer::Dot;
use File::Basename;

# ABSTRACT: dependency graph generator

=head1 NAME

analizo-graph - dependency graph generator

=head1 USAGE

  analizo graph [OPTIONS] <input> [<input> [<input> ...]]

=cut

sub usage_desc { "%c graph %o <input> [<input> [<input> ...]]" }

sub opt_spec {
  return (
    [ 'extractor=s', 'which extractor method use to parse the source code' ],
    [ 'output|o=s',  'output file name' ],
    [ 'omit=s',      'omit the given functions from the call graph', { default => '' } ],
    [ 'cluster',     'cluster the functions into files' ],
    [ 'modules',     'group the functions by modules(files)' ],
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
  my @omitted = split /,/, $opt->omit;
  my $graph = $extractor->model->callgraph(
    group_by_module => $opt->modules,
    omit => \@omitted,
  );
  if ($opt->output) {
    open STDOUT, '>', $opt->output or die "$!";
  }
  my $stdout = \*STDOUT;
  my $graph_writer = Graph::Writer::Dot->new(
    cluster => ($opt->cluster ? 'group' : undef),
  );
  $graph_writer->write_graph($graph, $stdout);
  close STDOUT;
}

=head1 DESCRIPTION

analizo graph reads the dependency information from one or more source code
directories passed as arguments, and produces as output the graph of
dependencies between the modules of the software in the graphviz(1) format.

analizo graph is part of the analizo suite.

=head1 REQUIRED ARGUMENTS

=over

=item <input>...

The input directories (or files) with source code to be processed.

Although you can pass individual files as input, this tool is more useful if
you pass entire source directories. If you pass just a couple of files, their
dependencies on modules that are not declared and/or implemented in those
files will not be calculated.

=back

=head1 OPTIONS

=over

=item --omit <functions>

Omit the given functions from the call graph. Multiple function names
may be given separated by commas.

=item --cluster

Cluster the functions into files, so you can see in which files are the calling
and called functions.

=item --modules

Group the functions by modules (files or OO classes), and only represent calls between
modules. This is useful to see the dependencies between the modules of the
program, instead of focusing on specific functions. The arrows between the
modules will be labelled with a number that represents the number of different
places in which the calling module calls functions in the called module (i.e.
how many times module A calls module B).

It doesn't make much sense to use --modules together with --cluster.

=item --extractor <extractor>

Define which extractor method use to parse the source code. Currently "Doxyparse"
is the only extractor available.  Default is Doxyparse.

=item --output <file>, -o <file>

Use a file as output

=back

=head1 VIEWING THE GRAPH

To view the generated graph, pipe analizo's output to one of the
Graphviz tools. You can use B<dotty(1)> to display the graph in a
X11 window:

  $ analizo graph src/ | dotty -

You can also generate a file to print or include in a document
by using the B<dot(1)>.

To generate a PNG image called F<graph.png>:

  $ analizo graph src/ | dot -Tpng -ograph.png -

To generate a PostScript version of the dependency graph for printing, you can
also use the B<dot>. For example, to generate a dependency graph in the file
F<graph.ps> fitting everything on a US letter size page in landscape mode, try

  $ analizo graph src/ | dot -Grotate=90 -Gsize=11,8.5 -Tps -o graph.ps

Sometimes, the graph will fit better if the dependencies arrows go from left to
right instead of top to bottom.  The B<dot> option B<-Grankdir=LR> will do
that:

  $ analizo graph src/ | dot -Gsize=8.5,11 -Grankdir=LR -Tps -o graph.ps

For large software, the graph may end up too small
to comfortably read.  If that happens, try N-up printing:

  $ analizo graph src/ | dot -Gpage=8.5,11 -Tps -o graph.ps

You can also try playing with other B<dot> options such as B<-Gratio>,
or for a different style of graph, try using B<neato> instead of
B<dot>. See the Graphviz documentation for more information about the
various options available for customizing the style of the graph.

=head1 READING THE GRAPH

When generating a graph in the function level (i.g. without the I<--modules>
option), function calls are displayed as solid arrows.  A dotted arrow means
that the function the arrow points from takes the address of the function the
arrow points to; this typically indicates that the latter function is being
used as a callback.

When the I<--modules> option is on, then there are only solid arrows. An arrow
from I<A> to I<B> means that I<A> depends on I<B>.

=head1 SEE ALSO

B<dotty(1)>, B<dot(1)>, B<neato(1)>, B<analizo(1)>

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
