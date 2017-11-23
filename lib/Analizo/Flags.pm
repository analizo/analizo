package Analizo::Flags;
use Analizo::Metrics;

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

sub has_list_flag() {
	my ($self, $opt) = @_;
    return $opt->list;
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

1;
