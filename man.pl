our %manpages = ();
for my $script (glob('lib/Analizo/Command/*')) {
  my $path = 'blib/man1/analizo-' . basename($script, '.pm') . '.1';
  $path =~ s/_/-/g;
  $manpages{$script} = $path;
}
$manpages{'lib/Analizo.pm'} = 'blib/man1/analizo.1';

