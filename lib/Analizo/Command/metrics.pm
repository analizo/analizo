package Analizo::Command::metrics;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Metrics;
use Analizo::Batch::Job::Directories;
use File::Basename;

# ABSTRACT: analizo's metric reporting tool

=head1 NAME

analizo-metrics - analizo's metric reporting tool

=head1 USAGE

  analizo metrics [OPTIONS] [<input>]

=cut

sub usage_desc { "%c metrics %o [<input>]" }

sub opt_spec {
  my ($class, $app) = @_;
  return (
    [ 'list|l',       'displays metric list' ],
    [ 'extractor=s',  'wich extractor method use to analise source code' ],
    [ 'globalonly|global-only|g', 'only output global (project-wide) metrics' ],
    [ 'output|o=s',   'output file name' ],
    [ 'language=s',   'process only filenames matching known extensions for the <lang>> programming' ],
    [ 'exclude|x=s',  'exclude <dirs> (a colon-separated list of directories) from the analysis' ],
  );
}

sub validate {
  my ($self, $opt, $args) = @_;
  if (@$args > 1) {
    $self->usage_error('No more than one <input> is suported');
  }
  my @unreadable = grep { ! -r $_ || ! -e $_ } @$args;
  if (@unreadable) {
    foreach my $file (@unreadable) {
      $self->usage_error("Input '$file' is not readable");
    }
  }
  if ($opt->output && ! -w dirname($opt->output)) {
    $self->usage_error("No such file or directory");
  }
}

sub execute {
  my ($self, $opt, $args) = @_;
  if($opt->list){
    my $metrics_handler = new Analizo::Metrics(model => new Analizo::Model);
    my %metrics = $metrics_handler->list_of_metrics();
    my %global_metrics = $metrics_handler->list_of_global_metrics();
    print "Global Metrics:\n";
    foreach my $key (sort keys %global_metrics){
      print "$key - $global_metrics{$key}\n";
    }
    print "\nModule Metrics:\n";
    foreach my $key (sort keys %metrics){
      print "$key - $metrics{$key}\n";
    }
    exit 0;
  }
  my $tree = $args->[0] || '.';
  my $job = new Analizo::Batch::Job::Directories($tree);
  $job->extractor($opt->extractor);
  if ($opt->language) {
    require Analizo::LanguageFilter;
    if ($opt->language eq 'list') {
      my @language_list = Analizo::LanguageFilter->list;
      print "Languages:\n";
      $" = "\n";
      print "@language_list\n";
      exit 0;
    }
    my $language_filter = Analizo::LanguageFilter->new($opt->language);
    $job->filters($language_filter);
  }
  if ($opt->exclude) {
    my @excluded_directories = split(':', $opt->exclude);
    $job->exclude(@excluded_directories);
  }
  $job->execute();
  my $metrics = $job->metrics;
  if ($opt->output) {
    open STDOUT, '>', $opt->output or die "$!\n";
  }
  if ($opt->globalonly) {
    print $metrics->report_global_metrics_only;
  }
  else {
    print $metrics->report;
  }
  close STDOUT;
}

=head1 DESCRIPTION

analizo metrics analyzes source code in I<input> and produces a metrics
report. If I<input> is ommitted, the current directory (I<.>) is assumed.

The produced report is written to the standard output, or to a file using the
I<--output> option, using the YAML format (see I<http://www.yaml.org/>)

analizo metrics is part of the analizo suite.

=head1 OPTIONS

=over

=item <input>

Tells analizo which source code directory you want to parse.

=item --extractor <extractor>

Define wich extractor method use to analise source code. Default is Doxyparse.

When using the Doxyparse extractor (default), all files matching the languages
supported by doxyparse are processed, unless I<--language> is used.

=item --list, -l

Displays metric list.

=item --output <file>, -o <file>

Writes the output to <file> instead of standard output.

=item --globalonly, --global-only, -g

Don't output the details about modules: only output global (project-wide) metrics.

=item --language <lang>

Process only filenames matching known extensions for the <I<lang>> programming
language. To see which languages are supported, pass B<--language list>.

=item --exclude <dirs>, -x <dirs>

Exclude <I<dirs>> (a colon-separated list of directories) from the analysis.
This is useful, for example, when you want to focus on production code and
exclude test code from the analysis. You could do that by passing something
like pass B<--exclude test>.

=back

=head1 OUTPUT FORMAT

The output is a stream of YAML documents. The first one presents metrics for
the project as a whole. The subsequent ones present per-module metrics, and thus
there will be as many of them as there are modules in your project.

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
