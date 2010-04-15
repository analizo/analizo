use ExtUtils::MakeMaker;

my @exe_files = glob('analizo*');

WriteMakefile(
  NAME => 'analizo',
  VERSION_FROM => 'analizo',
  EXE_FILES => \@exe_files,
  PMLIBDIRS => [ 'Analizo' ],
  AUTHOR => 'Antonio Terceiro <terceiro@softwarelivre.org>',
  LICENSE => 'perl',
  ABSTRACT => 'A dependency extractor for C/C++ projects',
  PREREQ_PM => {
      'Class::Accessor::Fast' => 0,
      'Test::Class' => 0,
      'Getopt::Euclid' => 0,
      'List::Compare' => 0,
      'Graph' => 0,
      'YAML' => 0,
      'Test::Exception' => 0,
      'Statistics::Descriptive' => 0,
  },
);
