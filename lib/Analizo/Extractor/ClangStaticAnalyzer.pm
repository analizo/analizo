package Analizo::Extractor::ClangStaticAnalyzer;

use base qw(Analizo::Extractor);

use Analizo::Extractor::ClangStaticAnalyzerTree;
use Cwd;
use File::Basename;
use File::Find;

sub new {
  my ($package, @options) = @_;
  return bless { files => [], @options }
}

sub actually_process {
  my ($self, @input_files) = @_;
  my @c_files;
  foreach my $file(@input_files) {
    push(@c_files, $file) if($file =~ m/\.c$/);
  }
  return if(scalar(@c_files) < 1);

  my $clang_tree = new Analizo::Extractor::ClangStaticAnalyzerTree;
  my $tree;
  my $file_report;
  my $files_list = join(' ', @c_files);
  my $output_folder = "/tmp/analizo-clang-analyzer";
  our $html_report;
  my @files;

  foreach my $c_file(@c_files) {

    my $analyze_command = "scan-build -o $output_folder gcc -c $c_file >/dev/null 2>/dev/null";

    #FIXME: Eval removed due to returning bug
    my $clang_return = system($analyze_command);

    $c_file =~ s/\.\///;

    if ($clang_return != 0){
      warn "The file [$c_file] was not compiled. System error: $clang_return\n";
    }

    find({wanted => sub {
          $html_report = $File::Find::name if m/index\.html/;
        }}, $output_folder);

    if(defined $html_report) {
      open ($file_report, '<', $html_report);

      while(<$file_report>){
        $tree = $clang_tree->building_tree($_, $c_file);
      }

      close ($file_report);
    }

    system("rm -rf $output_folder");

  }

  $self->feed($tree);

  foreach my $object_file(@c_files) {
    $object_file = fileparse($object_file, qr/\.[^.]*/);
    $object_file .= ".o";
    system("rm -f $object_file");
  }
}

sub feed {
  my ($self, $tree) = @_;

  foreach my $file_name (keys %$tree) {
    my $bugs_hash = $tree->{$file_name};

    my $module = $file_name;
    $module =~ s/\.[^.]*$//;

    $self->model->declare_module($module, $file_name);

    foreach $bug (keys $bugs_hash) {
      my $value = $tree->{$file_name}->{$bug};
      $self->model->declare_security_metrics($bug, $module, $value);
    }

#    if (defined $tree->{$file_name}->{'Division by zero'}) {
#      my $value = $tree->{$file_name}->{'Division by zero'};
#      $self->model->declare_security_metrics('Division by zero', $module, $value);
#    }
#    else {
#      $self->model->declare_security_metrics($module, 0);
#    }
#
#    if (defined $tree->{$file_name}->{'Dead assignment'}) {
#      my $value = $tree->{$file_name}->{'Dead assignment'};
#      $self->model->declare_dead_assignment($module, $value);
#    }
#    else {
#      $self->model->declare_dead_assignment($module, 0);
#    }
  }
}

1;

