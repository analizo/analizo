package Analizo::Extractor::Doxyparse;

use strict;
use warnings;

use base qw(Analizo::Extractor);

use File::Temp qw/ tempfile /;
use Cwd;

sub new {
  my ($package, @options) = @_;
  return bless { files => [], @options }, $package;
}

sub _add_file {
  my ($self, $file) = @_;
  push(@{$self->{files}}, $file);
}

sub _cpp_hack {
  my ($self, $module) = @_;
  my $current = $self->current_file;
  if (defined($current) && $current =~ /^(.*)\.(h|hpp)$/) {
    my $prefix = $1;
    # look for a previously added .cpp/.cc/etc
    my @implementations = grep { $_ =~ /^$prefix\.(cpp|cxx|cc)$/} @{$self->{files}};
    foreach my $impl (@implementations) {
      $self->model->declare_module($module, $impl);
    }
  }
}

sub feed {
  my ($self, $line) = @_;

  # current file declaration
  if ($line =~ /^file (.*)$/) {
    my $file = _strip_current_directory($1);
    $self->current_file($file);
    $self->_add_file($file);
  }

  # current module declaration
  if ($line =~ /^module (.+)$/) {
    my $modulename = _file_to_module($1);
    $self->current_module($modulename);
    $self->_cpp_hack($modulename);
  }

  # function declarations
  if ($line =~ m/^\s{3}function (.*) in line \d+$/) {
    my $function = _qualified_name($self->current_module, $1);
    $self->model->declare_function($self->current_module, $function);
    $self->{current_member} = $function;
  }
  # variable declarations
  elsif ($line =~ m/^\s{3}variable (.+) in line \d+$/) {
    my $variable = _qualified_name($self->current_module, $1);
    $self->model->declare_variable($self->current_module, $variable);
    $self->{current_member} = $variable;
  }
  
  #FIXME: Implement define treatment
  # define declarations
  elsif ($line =~ m/^\s{3}define (.+) in line \d+$/) {
    my $define = _qualified_name($self->current_module, $1);
    $self->{current_member} = $define;
  }

  # inheritance
  if ($line =~ m/^\s{3}inherits from (.+)$/) {
    $self->model->add_inheritance($self->current_module, $1);
  }

  # function calls/uses
  if ($line =~ m/^\s{6}uses function (.*) defined in (.+)$/) {
    my $function = _qualified_name($2, $1);
    $self->model->add_call($self->current_member, $function, 'direct');
  }

  # variable references
  elsif ($line =~ m/^\s{6}uses variable (.+) defined in (.+)$/) {
    my $variable = _qualified_name($2, $1);
    $self->model->add_variable_use($self->current_member, $variable);
  }

  # public members
  if ($line =~ m/^\s{6}protection public$/) {
    $self->model->add_protection($self->current_member, 'public');
  }

  # method LOC
  if($line =~ m/^\s{6}(\d+) lines of code$/){
    $self->model->add_loc($self->current_member, $1);
  }

  #method parameters
  if($line =~ m/^\s{6}(\d+) parameters$/) {
    $self->model->add_parameters($self->current_member, $1);
  }

  #method conditional paths
  if($line =~ m/^\s{6}(\d+) conditional paths$/){
    $self->model->add_conditional_paths($self->current_member, $1);
  }

  # abstract class
  if ($line =~ m/^\s{3}abstract class$/) {
    $self->model->add_abstract_class($self->current_module);
  }
}

# concat module with symbol (e.g. main::to_string)
sub _qualified_name {
  my ($file, $symbol) = @_;
  _file_to_module($file) . '::' . $symbol;
}

# discard file suffix (e.g. .c or .h)
sub _file_to_module {
  my ($filename) = @_;
  $filename ||= 'unknown';
  $filename =~ s/\.\w+$//;
  return $filename;
}

sub _strip_current_directory {
  my ($file) = @_;
  my $pwd = getcwd();
  $file =~ s#^$pwd/##;
  return $file;
}

sub actually_process {
  my ($self, @input_files) = @_;
  my ($temp_handle, $temp_filename) = tempfile();
  foreach my $input_file (@input_files) {
    print $temp_handle "$input_file\n"
  }
  close $temp_handle;

  eval {
    open DOXYPARSE, "doxyparse - < $temp_filename |" or die $!;
    while (<DOXYPARSE>) {
      $self->feed($_);
    }
    close DOXYPARSE;
    unlink $temp_filename;
  };
  if($@) {
    warn($@);
    exit -1;
  }
}

1;

