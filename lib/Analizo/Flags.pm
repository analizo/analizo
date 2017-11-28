package Analizo::Flags;

use strict;
use warnings;

my @binary_statistics = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

sub new {
   my ($class_name) = @_;
   my $new_instance = {};
   bless $new_instance, $class_name;
   return $new_instance;
}

sub get_binary {
	@binary_statistics;
}

sub has_list_flag {
	my ($self, $opt) = @_;
    return $opt->list;
}

sub has_language_flag {
	my ($self, $opt) = @_;
    return $opt->language;
}

sub has_exclude_flag {
	my ($self, $opt) = @_;
    return $opt->exclude;
}

sub has_output_flag {
	my ($self, $opt) = @_;
    return $opt->output;
}

sub has_global_only_flag {
	my ($self, $opt) = @_;
    return $opt->globalonly;
}

sub statistics_flags {
	my ($self, $opt) = @_;
	if($opt->all){
	    @binary_statistics = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	} else {
	    if($opt->mean) {
	      $binary_statistics[0] = 1;
	    }
	    if($opt->mode) {
	      $binary_statistics[1] = 1;
	    }
	    if($opt->standard) {
	      $binary_statistics[2] = 1;
	    }
	    if($opt->sum) {
	      $binary_statistics[3] = 1;
	    }
	    if($opt->variance) {
	      $binary_statistics[4] = 1;
	    }
	    if($opt->min) {
	      $binary_statistics[5] = 1;
	    }
	    if($opt->lower) {
	      $binary_statistics[6] = 1;
	    }
	    if($opt->median) {
	      $binary_statistics[7] = 1;
	    }
	    if($opt->upper) {
	      $binary_statistics[8] = 1;
	    }
	    if($opt->ninety) {
	      $binary_statistics[9] = 1;
	    }
	    if($opt->ninety_five) {
	      $binary_statistics[10] = 1;
	    }
	    if($opt->max) {
	      $binary_statistics[11] = 1;
	    }
	    if($opt->kurtosis) {
	      $binary_statistics[12] = 1;
	    }
	    if($opt->skewness) {
	      $binary_statistics[13] = 1;
	    }
    }
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
	my ($self, $metrics) = @_;
	print $metrics->report_global_metrics_only(@binary_statistics);
}

sub should_report_according_to_file() {
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
	my ($self, $metrics) = @_;
	print $metrics->report(@binary_statistics);
}

1;
