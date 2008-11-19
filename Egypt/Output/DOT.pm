package Egypt::Output::DOT;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);

Egypt::Output::DOT->mk_accessors(qw(filename));

sub new {
  my $package = shift;
  my @defaults = (
    filename => 'output.dot',
    calls => {},
  );
  return bless { @defaults, @_ }, __PACKAGE__;
}

sub string {
  my $self = shift;
  my $result = "digraph callgraph {\n";
  foreach my $caller (keys(%{$self->{calls}})) {
    foreach my $callee (keys(%{$self->{calls}->{$caller}})) {
      $result .= "\"$caller\" -> \"$callee\" [style=solid];\n";
    }
  }
  $result .= "}\n";

  return $result;
}

sub add_call {
  my $self = shift;
  my ($caller, $callee, $reftype) = @_;
  $self->{calls}->{$caller} = {} unless exists($self->{calls}->{$caller});
  $self->{calls}->{$caller}->{$callee} = $reftype;
}


1;

