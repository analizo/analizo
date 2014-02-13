package Analizo::Extractor::ClangStaticAnalyzer;

use base qw(Analizo::Extractor);

use Analizo::Extractor::ClangStaticAnalyzerTree;
use Cwd;
use File::Basename;
use File::Find;

my $include_dirs;
my $lib_dirs;
my $libs_list;

sub new {
  my ($package, $includedirs, $libdirs, $libs, @options) = @_;
  $include_dirs = $includedirs;
  $lib_dirs = $libdirs;
  $libs_list = $libs;
  return bless { files => [], @options }
}

sub include_flags {
  my ($self) = @_;
  if (not defined $include_dirs) {
    return "";
  }
  my @dirs = split(':', $include_dirs);
  my $flags = '-I'.join(' -I', @dirs);
  return $flags;
}

sub lib_flags {
  my ($self) = @_;
  my $dirs_flags;
  my $libs_flags;

  if (not defined $lib_dirs) {
    $dirs_flags = "";
  }
  else {
    my @dirs = split(':', $lib_dirs);
    $dirs_flags = '-L'.join(' -L', @dirs);
  }
  if (not defined $libs_list) {
    $libs_flags = "";
  }
  else {
    my @libs = split(',', $libs_list);
    $libs_flags = '-l'.join(' -l', @libs);
  }
  my $flags = $dirs_flags." ".$libs_flags;
  return $flags;
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
  my $analizo_folder = "/tmp/analizo-clang-analyzer";
  my $output_folder = "";
  my $html_report;
  my @files;
  my $flags = "";
  my $clang_return;

  $flags = include_flags()." ".lib_flags();

  foreach my $c_file(@c_files) {

    #FIXME: Eval removed due to returning bug
    $clang_return = `scan-build -o $analizo_folder gcc -c $c_file $flags 2>&1`;

    $c_file =~ s/\.\///;

    if ($clang_return =~ m/error/ and $clang_return =~ m/contains no reports\./){
      warn "The file [$c_file] was not compiled.\n";
    }
    elsif($clang_return =~ m/scan-view $analizo_folder\/([^']+)/) {
      $output_folder = $analizo_folder."/".$1;
      $html_report = $output_folder."/index.html";

      open ($file_report, '<', $html_report) or die $!;

      while(<$file_report>){
        $tree = $clang_tree->building_tree($_, $c_file);
      }

      close ($file_report);

      `rm -rf $output_folder`;
    }
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
  }
}

1;

