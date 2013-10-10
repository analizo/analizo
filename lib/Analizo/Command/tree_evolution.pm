package Analizo::Command::tree_evolution;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use Digest::SHA qw(sha1_hex);
use File::Basename;
use Analizo::LanguageFilter;

#ABSTRACT:  watch the evolution of the source code

=head1 NAME

analizo tree-evolution - watch the evolution of the source code

=head1 USAGE

  analizo tree-evolution [OPTIONS]

=cut

sub command_names { qw/tree-evolution/ }

sub opt_spec {
  return (
    [ 'language|l=s', 'filters the source tree by language', { default => 'all' } ],
  );
}

sub validate {}

sub execute {
  my ($self, $opt, $args) = @_;
  my $filter = new Analizo::LanguageFilter($opt->language);
  local $ENV{PATH} = '/usr/local/bin:/usr/bin:/bin';
  open COMMITS, "git log --reverse --format=%H|";
  my @commits = <COMMITS>;
  chomp @commits;
  close COMMITS;
  my %trees = ();
  for my $commit (@commits) {
    my @tree = `git ls-tree -r --name-only $commit`;
    chomp(@tree);
    my %dirs = map { dirname($_) => 1 } (grep { $filter->matches($_) } @tree);
    @tree = sort(grep { $_ ne '.' } keys(%dirs));
    next unless (@tree);
    my $tree = join("\n", @tree);
    my $sha1 = sha1_hex($tree);
    if (!exists($trees{$sha1})) {
      print "# $commit\n";
      print $tree, "\n";
      $trees{$sha1} = 1;
    }
  }
}

1;

=head1 DESCRIPTION

Watch the evolution of the source code tree in a Git repository.

When run inside a Git repository, B<analizo tree-evolution> will output all
different sets of directories found in the project's history. For each commit
in which a new directory was added or removed, you will have the commit hash
and a snapshot of the source code tree at that commit.

For example, consider the following sample execution of B<analizo
tree-evolution> against a sample Git repository:

  $ analizo tree-evolution
  # 073290fbad0254793bd3ecfb97654c04368d0039
  src
  # 85f7db08f7b7b0b62e3c0023b2743d529b0d5b4b
  src
  src/input
  # f41cf7d0351e812285efd60c6d957c330b1f61a1
  src
  src/input
  src/output

The output shows us the following information:

=over

=item

Commit I<073290fbad0254793bd3ecfb97654c04368d0039> was the first commit in the
project, and back then the project had a "src" directory.

=item

In commit I<85f7db08f7b7b0b62e3c0023b2743d529b0d5b4b>, a directory called
src/input was added to the tree.

=item

Finally, commit I<f41cf7d0351e812285efd60c6d957c330b1f61a1> introduced another
directory called src/output.

=back

=head1 OPTIONS

=over

=item --language LANGUAGE, -l LANGUAGE

Filters the source tree by language. When determining the contents of the
source tree, only consider directories that contain files that match the
expected file extensions for LANGUAGE.

LANGUAGE can be one of I<c>, I<cpp> and I<java>. The default behaviour is to
condider all files in the repository.

=back

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut
