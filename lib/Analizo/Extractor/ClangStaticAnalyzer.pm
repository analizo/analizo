package Analizo::Extractor::ClangStaticAnalyzer;

use base qw(Analizo::Extractor);

use Analizo::Extractor::ClangStaticAnalyzerTree;
use Cwd;
use File::Basename;

sub new {
  my ($package, @options) = @_;
  return bless { files => [], @options }
}

sub actually_process {
  my ($self, @input_files) = @_;
  my $clang_tree = new Analizo::Extractor::ClangStaticAnalyzerTree;
  my $tree;
  my $file_report;
  my $files_list = join(' ', @input_files);
  my $output_folder = "/tmp/analizo-clang-analyzer";

  my $analyze_command = "scan-build -o $output_folder gcc -c $files_list >/dev/null 2>/dev/null";

  #FIXME: Eval removed due to returning bug
  system($analyze_command);
  my $html_report = glob("$output_folder/*/index.html");

  open ($file_report, '<', $html_report) or die $!;

  while(<$file_report>){
    $tree = $clang_tree->building_tree($_);
  }

  close ($file_report);

  system("rm -rf $output_folder");

  $self->feed($tree);

  foreach my $object_file(@input_files) {
    $object_file = fileparse($object_file, qr/\.[^.]*/);
    $object_file .= ".o";
    system("rm $object_file");
  }
}

sub feed {
  my ($self, $tree) = @_;

}

1;


