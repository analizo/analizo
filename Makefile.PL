use ExtUtils::MakeMaker;
use File::Basename;

my %manpages = ();
for my $script (glob('lib/Analizo/scripts/*')) {
  $manpages{$script} = 'blib/man1/' . basename($script) . '.1';
}
$manpages{'analizo'} = 'blib/man1/analizo.1';

WriteMakefile(
  NAME => 'analizo',
  VERSION_FROM => 'analizo',
  EXE_FILES => ['analizo'],
  MAN1PODS => \%manpages,
  AUTHOR => 'Antonio Terceiro <terceiro@softwarelivre.org>',
  LICENSE => 'perl',
  ABSTRACT => 'Source code analysis toolkit',
  PREREQ_PM => {
    'Class::Accessor::Fast' => 0,
    'Digest::SHA1' => 0,
    'List::Compare' => 0,
    'Graph' => 0,
    'YAML' => 0,
    'Statistics::Descriptive' => 0,
    'ZeroMQ' => 0,
  },
  BUILD_REQUIRES => {
    'Test::Class' => 0,
    'Test::Exception' => 0,
    'Test::MockObject' => 0,
    'Test::MockModule' => 0,
  },
);
