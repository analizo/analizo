package Analizo::Flag::ExecuteMetrics;

use strict;
use warnings;

sub new {
   my ($class_name) = @_;
   my $new_instance = {};
   bless $new_instance, $class_name;
   return $new_instance;
}

sub print_metrics_list {
	require Analizo::Metrics;
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
}

sub print_metrics_according_to_language {
	my ($self, $opt, $job) = @_;
	require Analizo::LanguageFilter;
    if ($opt->language eq 'list') {
      my @language_list = Analizo::LanguageFilter->list;
      print "Languages:\n";
      $" = "\n";
      print "@language_list\n";
    }
    my $language_filter = Analizo::LanguageFilter->new($opt->language);
    $job->filters($language_filter);
}

sub exlude_dir_from_execution {
	my ($self, $opt, $job) = @_; 
	my @excluded_directories = split(':', $opt->exclude);
    $job->exclude(@excluded_directories);
}

sub open_output_file {
	my ($self, $opt) = @_;
	open(STDOUT, '>', $opt->output);
}


sub close_output_file {
	my ($self) = @_;
	close STDOUT;
}

sub print_only_global_metrics {	
	my ($self, $metrics, @binary_statistics) = @_;
	print $metrics->report_global_metrics_only(@binary_statistics);
}

sub should_report_according_to_file {
	my ($self, @binary_statistics) = @_;
	my $all_zeros = is_all_zeroes(\@binary_statistics);
	return $all_zeros;
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

sub print_metrics_according_to_file() {
	my ($self, $metrics) = @_;
	print $metrics->report_according_to_file;
}

sub print_metrics_according_to_statistics {
	my ($self, $metrics, @binary_statistics) = @_;
	print $metrics->report(@binary_statistics);
}

1;
