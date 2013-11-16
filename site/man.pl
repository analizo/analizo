use File::Basename;
use Data::Dumper;

chdir('..');
do 'man.pl';
chdir('site');

mkdir('man');

my @index = ();

for my $source (keys(%manpages)) {
  my $target =  $manpages{$source};
  $target =~ s/blib\/man[0-9]/man/;
  $target =~ s/\.1$/.html/;
  my $intermediary = $target;
  $intermediary =~ s/\.html$/.pm/;
  my $dir = dirname($intermediary);
  print "MAN2HTML += $target\n";
  print "$intermediary: ../$source\n";
  print "\t\@mkdir -p $dir\n";
  print "\t\@cp \$< \$@\n";
  print "$target: $intermediary\n";

  my $cmd = basename($target);
  $cmd =~ s/\.html$//;
  push @index, $cmd;
}

open(MANINDEX, '>', 'man/index.pm');

print MANINDEX <<EOF;

=head1 Manual pages

The following manual pages are available:

=begin html

EOF

print MANINDEX "<ul>\n";
for my $cmd (sort(@index)) {
  print MANINDEX "<li><a href='$cmd.html'>$cmd</a></li>\n";
}
print MANINDEX "</ul>\n\n";

print MANINDEX "=end html\n";
close(MANINDEX);

print "man/index.html: man/index.pm\n";
print "MAN2HTML += man/index.html\n";
