package Analizo::Command::metrics_history;
use Analizo -command;
use parent qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Batch::Git;

#ABSTRACT: processes a Git repository collection metrics

=head1 NAME

analizo-metrics-history - processes a Git repository collection metrics

=head1 USAGE

  analizo metrics-history [OPTIONS] [<input>]

=cut

sub usage_desc { "%c metrics-history %o [<input>]" }

sub command_names { qw/metrics-history/ }

sub opt_spec {
  return (
    [ 'output|o=s',    'output file name' ],
    [ 'list|l',        'just print out the ids of the commits that would be processed '],
    [ 'language=s',    'process only filenames matching known extensions for the <lang> programming' ],
    [ 'exclude|x=s',   'exclude <dirs> (a colon-separated list of directories) from the analysis' ],
    [ 'parallel|p=i',  'activates support for parallel processing' ],
    [ 'format|f=s',    'specifies the output format', { default => 'csv' } ],
    [ 'progressbar|b', 'displays a progress bar during the execution' ],
  );
}

sub validate {
  my ($self, $opt, $args) = @_;
  unless ($self->output_driver($opt->format)) {
    $self->usage_error("Invalid output driver " . $opt->format);
  }
}

sub output_driver {
  my ($self, $format) = @_;
  my %available_outputs = (
    csv => 'Analizo::Batch::Output::CSV',
    db  => 'Analizo::Batch::Output::DB',
  );
  $available_outputs{$format};
}

sub load_output_driver {
  my ($self, $format) = @_;
  my $output_driver = $self->output_driver($format);
  eval "require $output_driver";
  return $output_driver->new;
}

sub execute {
  my ($self, $opt, $args) = @_;
  my $batch = Analizo::Batch::Git->new(@$args);
  if ($opt->list) {
    while (my $job = $batch->next()) {
      print $job->id, "\n";
    }
    exit 0;
  }
  if ($opt->language) {
    require Analizo::LanguageFilter;
    my $language_filter = Analizo::LanguageFilter->new($opt->language);
    $batch->filters($language_filter);
  }
  if ($opt->exclude) {
    my @excluded_directories = split(':', $opt->exclude);
    $batch->exclude(@excluded_directories);
  }
  my $output = $self->load_output_driver($opt->format);
  if ($opt->output) {
    $output->file($opt->output);
  }
  my $runner = undef;
  if ($opt->parallel) {
    require Analizo::Batch::Runner::Parallel;
    $runner = Analizo::Batch::Runner::Parallel->new($opt->parallel);
  } else {
    require Analizo::Batch::Runner::Sequential;
    $runner = Analizo::Batch::Runner::Sequential->new;
  }
  if ($opt->progressbar) {
    require Term::ProgressBar;
    my $progressbar = Term::ProgressBar->new({ count => 100, ETA => 'linear' });
    $runner->progress(
      sub {
        my ($job, $done, $total) = @_;
        $progressbar->update(100 * $done / $total);
      }
    );
  }
  $runner->run($batch, $output);
}

1;

=head1 DESCRIPTION

Processes a Git repository collection metrics for every single revision.

B<analizo metrics-history> will process I<input>, a Git repository with a
working copy of the source code (i.e. not a bare git repository), checkout
every relevant commit and run B<analizo metrics> on it. The metrics for all of
the revisions will be accumulated in a file called I<metrics.csv> inside
I<input>. If I<input> is omitted, the current directory (.) s
assumed.

analizo metrics-history is part of the analizo suite.

=head1 RELEVANT COMMITS

B<analizo metrics-history> considers as relevant the commits that changed at
least one source code file. Consequently, it skips all the commits where no
source code file was changed, such as documentation, translations, build system
changes, etc.

Currently we support C, C++, Java and C# projects, and therefore files considered
source code are the ones terminated in I<.c>, I<.h>, I<.cpp>, I<.cxx>, I<.cc>,
I<.hh>, I<.hpp>, I<.java> and I<.cs>.

=head1 OPTIONS

=over

=item --parallel N, -p N

Activates support for parallel processing, using I<N> concurrent worker
processes. Usually you will want N to be less than or equal to the number of
CPUs in your machine.

Note that analizo metrics extraction is a CPU-intensive process, so setting N
as the exacty number of CPUs you have may bring your machine to an unusable
state.

=item --language LANGUAGE, --exclude DIRECTORY

Use programming language and directory exclusion filters. See
B<analizo-metrics(1)> for a description of these options.

=item --output <file>, -o <file>

Make the output be written to I<file>. The default value and valid values
depend on the output format, see "Output formats" below.

=item --format FORMAT, -f FORMAT

Specifies with output driver, and consequently the output format, to use. See
"Output Formats" below for a description of the available output drivers.

=item --list, -l

Instead of actually processing the history, just print out the ids of the
commits that would be processed.

=item --progressbar, -b

Displays a progress bar during the execution, so that you know approximately how
long analizo is going to take to finish.

=back

=head1 Output formats

Using the I<--format> option, you can use the following output drivers:

=head2 csv

This is the default output driver. By default, the output will be written to
the standard output. If can direct the output to a file using the I<--output>
option.

=head2 db

Stores the extracted data in a relational database.

When you use this driver, you can specify where exactly to store the data using
the I<--output> option. If you do not specify an explicit target, analizo will
write to a SQLite database in a file called I<output.sqlite3> in the current
directory. If you pass a filename, and analizo will store the data in a SQLite
database that will be created on that file. You can direct the output to any
other database by using I<--output DSN>, where I<DSN> is a DBI Data Source
Name.

You can check B<DBI>(3pm) for details. Note that if you a database other than
SQLite, you must make sure that you have the correponsing DBI driver installed.

Examples:

B<$ analizo metrics-history -f db -o history.db>

Writes the output to a SQLite database called I<history.db>.

B<$ analizo metrics-history -f db -o 'dbi:Pg:dbname=pgdb'>

Writes the data to a PostgreSQL database called I<pgdb>. This requires the
I<DBI::Pg> Perl module.

analizo was not tested with MySQL yet.

=head1 SEE ALSO

B<analizo-metrics(1)>

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut
