package Analizo::Flag::Flags;

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

sub has_parallel_flag {
    my ($self, $opt) = @_;
    return $opt->parallel;
}

sub has_progressbar_flag {
    my ($self, $opt) = @_;
    return $opt->progressbar;
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

1;
