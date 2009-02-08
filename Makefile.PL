use ExtUtils::MakeMaker;

my $version = `perl -ne 'if (/applies to egypt version/) { s/.*version //; s/[^0-9]*\$//; print  }' egypt`;
chomp $version;
unless ($version =~ /^\d+.\d+$/) {
  die "Invalid version read from documentation: [$version]. There is something wrong with this package.\n";
}

WriteMakefile(
  NAME => 'egypt',
  VERSION => $version,
  EXE_FILES => [ 'egypt' ],
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
  },
);
