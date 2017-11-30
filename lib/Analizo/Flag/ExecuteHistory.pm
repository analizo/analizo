package Analizo::Flag::ExecuteHistory;

use strict;
use warnings;

sub new {
   my ($class_name) = @_;
   my $new_instance = {};
   bless $new_instance, $class_name;
   return $new_instance;
}

sub print_metrics_list {
	my ($self, $batch) = @_;
	while (my $job = $batch->next()) {
      print $job->id, "\n";
    }
}

sub set_language_filter {
	my($self, $opt, $batch) = @_;
	require Analizo::LanguageFilter;
    my $language_filter = Analizo::LanguageFilter->new($opt->language);
    $batch->filters($language_filter);
}

sub exclude_directories_from_report {
	my($self, $opt, $batch) = @_;
	my @excluded_directories = split(':', $opt->exclude);
    $batch->exclude(@excluded_directories);
}

sub set_output_file {
	my ($self, $opt, $output) = @_;
	$output->file($opt->output);
}

1;