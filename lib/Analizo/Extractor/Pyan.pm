package Analizo::Extractor::Pyan;

use strict;
use warnings;

use parent qw(Analizo::Extractor);

use File::Temp qw/ tempfile /;
use Cwd;
use File::Spec::Functions qw/ tmpdir /;

sub new {
  my ($package, @options) = @_;
  return bless { files => [], @options }, $package;
}

sub _add_file {
  my ($self, $file) = @_;
  push(@{$self->{files}}, $file);
}


sub feed {
  my ($self, $pyan_output, $line) = @_;

  if ($@) {
    die $!;
  }

  my %id_to_node = ();

  my @lines = split(/\n/, $pyan_output);
  my $i = 0;

  while ($lines[$i] !~ /#/) {
    my @values = split(/ /, $lines[$i]);

    my $id = $values[0];
    my $name = $values[1];
    my $type = $values[2];
    my @details = ();

    my $len  = int(scalar @values);
    if($len > 3) {
      @details = @values[3..$len-1];
    }

    @id_to_node{$id} = {
      name => $name,
      type => $type,
      details => \@details
    };

    if ($type =~ /abstract_class/) {
      my $class = $name;
      my $file = $details[0];
      $file =~ s/.\///;


      $self->model->declare_module($class, $file);
      $self->model->add_abstract_class($class)
    } 
    
    if ($type =~ /module/) {
      my $file = $details[0];
      $file =~ s/.\///;
      my $module = $name;

      $self->model->declare_module($module, $file);
    }
    if ($type =~ /class/) {
      my $class = $name;
      my $file = $details[0];
      $file =~ s/.\///;


      $self->model->declare_module($class, $file);
    }

    $i += 1;
  }

  $i += 1;

  while ($i < scalar(@lines)) {
    my @values = split(/ /, $lines[$i]);

    my $node1 = $id_to_node{$values[0]};
    my $node2 = $id_to_node{$values[1]};
    my $relation = $values[2];

    if ($relation =~ /U/) {

      if ($node1->{type} =~ /module/) {
        $i += 1;
        next;
      }

      if ($node2->{type} =~ /function/ || $node2->{type} =~ /method/) {
      my $class = $node1->{name};
      my $function = $node2->{name};
      
        $self->model->add_call($class, $function, 'direct');
      }
      elsif ($node2->{type} =~ /member_variable/) {
        my $function = $node1->{name};
        my $variable = $node2->{name};
        $self->model->add_variable_use($function, $variable);
      }
    }
    elsif ($relation =~ /I/) {
      my $class = $node1->{name};
      my $who = $node2->{name};
      $self->model->add_inheritance($class, $who);
    }
    elsif ($relation =~ /D/) {

      if ($node2->{type} =~ /function/ || $node2->{type} =~ /method/) {
        my $class = $node1->{name};
        my $function = $node2->{name};
        my $protection = $node2->{details}[0];
        my $loc = int($node2->{details}[1]);
        my $parameters = int($node2->{details}[2]);
        my $conditional_paths = int($node2->{details}[3]);
        

        $self->model->declare_function($class, $function);
        $self->model->add_protection($function, $protection);
        $self->model->add_loc($function, $loc);               
        $self->model->add_parameters($function, $parameters);
        $self->model->add_conditional_paths($function, $conditional_paths);

      }
      elsif ($node2->{type} =~ (/member_variable/)) {
        my $function = $node1->{name};
        my $variable = $node2->{name};
        my $protection = $node2->{details}[0];


        $self->model->add_protection($variable, $protection);
        $self->model->declare_variable($function, $variable);
      }
    }
    $i += 1;
  }
}

sub actually_process {
  my ($self, @input_files) = @_;
  my ($temp_handle, $temp_filename) = tempfile();
  foreach my $input_file (@input_files) {
    print $temp_handle "$input_file\n"
  }
  close $temp_handle;

  eval {
    local $ENV{TEMP} = tmpdir();

    open PYAN, "pyan-analizo --uses --inherits --defines --grouped --annotated --tgf \$(cat $temp_filename) |" or die "can't run pyan: $!";

    local $/ = undef;
    my $pyan_output = <PYAN>;
    close PYAN or die "pyan-analizo error";
    $self->feed($pyan_output);
    unlink $temp_filename;
  };
  if($@) {
    warn($@);
    exit -1;
  }
}

1;
