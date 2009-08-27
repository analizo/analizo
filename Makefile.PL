use ExtUtils::MakeMaker;

my @exe_files = glob('egypt*');

WriteMakefile(
  NAME => 'egypt',
  VERSION_FROM => 'egypt',
  EXE_FILES => \@exe_files,
  PMLIBDIRS => [ 'Egypt' ],
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
  },
);
