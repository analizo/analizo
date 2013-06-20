use ExtUtils::MakeMaker;
use File::ShareDir::Install;
use File::Basename;

do 'man.pl';

sub CheckExtraDependencies {
  my ($type, %dependencies) = @_;
  my $missing = 0;
  my $error_type = ($type eq 'runtime') ? 'E' : 'W';
  for my $program (keys(%dependencies)) {
    if (system("which $program > /dev/null") != 0) {
      print STDERR "$error_type: Required $type dependency not found: $program\n";
      $missing++;
    }
  }
  exit(1) if ($missing && $type eq 'runtime');
}

CheckExtraDependencies(
  'runtime',
  'doxyparse' => '(>= 1.5.8-12~)',
  'git' => 0,
  'ruby' => 0,
  'sloccount' => 0,
  'sqlite3' => 0,
  'man' => 0,
  'clang-3.5' => '(>= 3.5)',
  'gcc' => '(>= 4.8~)',
  'g++' => '(>= 4.8~)',
);
CheckExtraDependencies(
  'build',
  'cucumber' => 0,
  'file' => 0,
  'rake' => 0,
  'rspec' => 0,
);

install_share 'share';

WriteMakefile(
  NAME => 'Analizo',
  VERSION_FROM => 'lib/Analizo.pm',
  EXE_FILES => ['analizo'],
  MAN1PODS => \%manpages,
  MAN1EXT => '1',
  MAN3PODS => {},
  AUTHOR => 'Antonio Terceiro <terceiro@softwarelivre.org>',
  LICENSE => 'GPLv3+',
  ABSTRACT => 'Source code analysis toolkit',
  PREREQ_PM => {
    'Class::Accessor' => 0,
    'DBD::SQLite' => 0,
    'DBI' => 0,
    'CHI' => 0,
    'Digest::SHA' => 0,
    'File::Copy::Recursive' => 0,
    'List::Compare' => 0,
    'JSON' => 0,
    'Graph' => 0,
    'YAML' => 0,
    'Statistics::Descriptive' => 0,
    'Term::ProgressBar' => 0,
    'ZeroMQ' => 0,
    'Mojolicious' => 0,
    'File::ShareDir' => 0,
    'File::Share' => 0,
    'File::HomeDir' => 0,
    'YAML::Tiny' => 0,
    'App::Cmd' => 0,
    'Class::Inspector' => 0,
    'Graph::Writer::DSM' => 0.005,
    'FindBin::libs' => 0,
  },
  BUILD_REQUIRES => {
    'Test::Class' => 0,
    'Test::Exception' => 0,
    'Test::MockObject' => 0,
    'Test::MockModule' => 0,
    'Test::BDD::Cucumber' => 0,
    'Method::Signatures' => 0,
    'File::Slurp' => 0,
    'File::Copy::Recursive' => 0,
  },
  test => {
    TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t',
  },
);

package MY;
use File::ShareDir::Install qw(postamble);
