package Analizo::Flag::ExecuteMetrics;

use strict;
use warnings;
use Data::Dumper;

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
    my ($self, $opt ) = @_;
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

sub print_model_output {

    my ($self, $opt, $job) = @_; 

    if($opt->output_model){
        my $hash_of_model = $job->get_model();
        my $model = format_model($hash_of_model);
        
        open(STDOUT, '>', $opt->output_model);
        print ($model);
        $self->close_output_file();
    }
}

sub format_model() {
    my ($hash_of_model) = @_; 

    my $model = Dumper($hash_of_model);
    $model = replace_sub_string($model);
    $model = remove_extra_spaces($model);

    return $model;
}

sub remove_extra_spaces(){
    my ($model) = @_; 

    my $unindent_fifteen_spaces = "               "; #15 spaces
    my $value_to_replace = "";
    my $changed_line = 0;

    my $temporary_model = "";
    my @lines = split /\n/, $model; 
    foreach my $line( @lines ) { 
      $line =~ s/\Q$unindent_fifteen_spaces/$value_to_replace/i;
      $temporary_model = $temporary_model . $line . "\n";
    }
    return $temporary_model;
}

sub replace_sub_string(){
  my ($model) = @_;

  my @SUBSTRINGS_TO_REMOVE = ( "\$VAR1 = bless( ", ", 'Analizo::Model' );" );
  my $substring_to_replace = "";

  foreach my $substring_to_remove (@SUBSTRINGS_TO_REMOVE) {
    $model =~ s/\Q$substring_to_remove/$substring_to_replace/ig;
  }
  
  return $model;
}

1;
