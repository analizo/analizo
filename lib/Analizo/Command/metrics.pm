package Analizo::Command::metrics;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use Analizo::Metrics;
use Analizo::Batch::Job::Directories;
use File::Basename;
use Analizo::Flags;

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
    [ 'all|a', 'displays all metrics'],
    [ 'extractor=s',  'wich extractor method use to analise source code' ],
    [ 'globalonly|global-only|g', 'only output global (project-wide) metrics' ],
    [ 'output|o=s',   'output file name' ],
    [ 'language=s',   'process only filenames matching known extensions for the <lang>> programming' ],
    [ 'exclude|x=s',  'exclude <dirs> (a colon-separated list of directories) from the analysis' ],
    [ 'includedirs|I=s',  'include <dirs> (a colon-separated list of directories) with C/C++ header files', { default => '.' } ],
    [ 'libdirs|L=s',  'include <dirs> (a colon-separated list of directories) with C/C++ static and dynamic libraries files', { default => '.' } ],
    [ 'libs=s',  'include <dirs> (a colon-separated list of directories) with C/C++ linked libraries files', { default => '.' } ],
    [ 'mean',  'display only mean statistics'],
    [ 'mode',  'display only mode statistics'],
    [ 'standard',  'display only standard deviation statistics'],
    [ 'sum',  'display only sum statistics'],
    [ 'variance',  'display only variance statistics'],
    [ 'min',  'display only quantile min statistics'],
    [ 'lower',  'display only quantile lower statistics'],
    [ 'median',  'display only quantile median statistics'],
    [ 'upper',  'display only quantile upper statistics'],
    [ 'ninety',  'display only quantile ninety statistics'],
    [ 'ninety_five',  'display only quantile ninety-five statistics'],
    [ 'max',  'display only quantile max statistics'],
    [ 'kurtosis',  'display only kurtosis statistics'],
    [ 'skewness',  'display only skewness statistics'],
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
  my $flags = Analizo::Flags->new;
  $flags->statistics_flags($opt);
  my @binary_statistics = $flags->get_binary;
  if ($flags->has_list_flag($opt)) {
    $flags->print_metrics_list;
  }
  my $tree = $args->[0] || '.';
  my $job = new Analizo::Batch::Job::Directories($tree);
  $job->extractor($opt->extractor);
  if ($flags->has_language_flag($opt)) {
    $flags->print_metrics_according_to_language($opt, $job);
  }
  if ($opt->exclude) {
    my @excluded_directories = split(':', $opt->exclude);
    $job->exclude(@excluded_directories);
  }
  $job->includedirs($opt->includedirs);
  $job->libdirs($opt->libdirs);
  $job->libs($opt->libs);
  $job->execute();
  my $metrics = $job->metrics;
  if ($opt->output) {
    open STDOUT, '>', $opt->output or die "$!\n";
  }
  if ($opt->globalonly) {
    print $metrics->report_global_metrics_only(@binary_statistics);
  }
  else {
		my $all_zeroes = is_all_zeroes(\@binary_statistics);
		if($all_zeroes == 0){
    	print $metrics->report(@binary_statistics);
		}else{
			print $metrics->report_according_to_file;
		}
  }
  close STDOUT;
}

sub is_all_zeroes{
	my @metrics_array = @{$_[0]};

	my $all_zeros = 1;
	foreach my $metrics_position (@metrics_array) {
			if($metrics_position != 0) {
				$all_zeros = 0;
				last; # One not equal to zero is enough to know if all values are zeros
			}
	}
	return $all_zeros;
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
