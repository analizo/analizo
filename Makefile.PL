use ExtUtils::MakeMaker;
WriteMakefile(
  NAME => 'egypt',
  VERSION_FROM => 'egypt',
  EXE_FILES => [ 'egypt' ],
  PMLIBDIRS => [ 'Egypt' ],
  AUTHOR => 'Antonio Terceiro <terceiro@softwarelivre.org>',
  LICENSE => 'perl',
  ABSTRACT => 'A dependency extractor for C/C++ projects',
  PREREQ_PM => {
      'Class::Accessor::Fast' => 0,
      'Test::Class' => 0,
  },
);
