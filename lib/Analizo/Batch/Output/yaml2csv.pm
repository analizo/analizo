use strict;
use warnings;
package Analizo::Batch::Output::yaml2csv;

sub new 
{
  my ($class, @yaml_file) = @_;
  return bless {job_directory => @yaml_file}, $class;
}

sub extract_labels
{
  my ($self) = @_;
  my @labels = ();

  open(my $yaml_handler, "<", $self->{job_directory} . "-details.yml")  || return 0;

  while(!eof $yaml_handler)
  { 
    my $line = readline $yaml_handler;
    if($line ne "---\n" and $line =~ m/(\w+):/)
    {
      push @labels, $1;
      if($1 eq "sc")
      {
        close $yaml_handler;
        last;
      }
    }
  }
    
  return @labels;
}


sub extract_lines
{
  my ($self, $number_of_labels) = @_;
  my @values = ();
  my @array_of_values = ();
  my @files_names = ();

  open(my $yaml_handler, "<", $self->{job_directory} . "-details.yml")  || return 0;  
  
  while(my $line = readline $yaml_handler)
  {
    if($line =~ m/( .*)/)
    {
      if($1 =~ m/(- (.*))/ )
      {
        push @files_names, $1." ";
      }
      else
      {
        push @values, $1;  
      }
      if($number_of_labels == ((@values)+1))
      { 
        push @array_of_values, @files_names;
        push @array_of_values, ",";
        push @array_of_values, join(",", @values);
        push @array_of_values, "\n";
        @values = ();
        @files_names = ();
      }
    }
  } 
  close $yaml_handler;
  return @array_of_values;
}

sub write_csv 
{
  my ($self) = @_;
  my $csv_filename = $self->{job_directory} . "-details.csv";
  
  open my $csv_handler, '>'.$csv_filename  || die "Cannot open ".$self->{job_directory} . "-details.csv\n".$!;

  my $number_of_labels = $self->extract_labels();
  print $csv_handler join(",", $self->extract_labels());
  print $csv_handler "\n";

  my @array_of_values =  $self->extract_lines($number_of_labels);
  foreach(@array_of_values)
  {
     print $csv_handler $_;  
  }

  close $csv_handler;
}

1;
