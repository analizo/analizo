use strict;
use warnings;
use Test::More;
use Test::BDD::Cucumber::StepFile;
use Method::Signatures;
use Cwd;
use File::Slurp;
use File::Temp qw( tempdir );
use File::Copy::Recursive qw( rcopy );

our $top_dir = cwd();
our $saved_path = $ENV{PATH};

$ENV{LC_ALL} = 'C';
$ENV{PATH} = "$top_dir:$ENV{PATH}";

END {
  chdir $top_dir;
  $ENV{PATH} = $saved_path;
};

our $exit_status;
our $stdout;
our $stderr;

sub run {
  my ($command) = @_;
  $exit_status = system "($command) >tmp.out 2>tmp.err";
  $stdout = read_file('tmp.out');
  $stderr = read_file('tmp.err');
}

When qr/^I run "([^\"]*)"$/, func($c) {
  run $1;
};

Then qr/^the output must match "([^\"]*)"$/, func($c) {
  like($stdout, qr/$1|\Q$1\E/);
};

Then qr/^the output must not match "([^\"]*)"$/, func($c) {
  unlike($stdout, qr/$1|\Q$1\E/);
};

Then qr/^the exit status must be (\d+)$/, func($c) {
  cmp_ok($exit_status, '==', $1);
};

Then qr/^the exit status must not be (\d+)$/, func($c) {
  cmp_ok($exit_status, '!=', $1);
};

Step qr/^I copy (.*) into a temporary directory$/, func($c) {
  my $tmpdir = tempdir(CLEANUP => 1);
  rcopy(glob($1), $tmpdir);
  chdir $tmpdir;
};

Given qr/^I create a file called (.+) with the following content$/, func($c) {
  open FILE, '>', $1 or die $!;
  if ($c->data =~ m/<\w+>/) {
    # O Test::BDD::Cucumber nao substitui a string <key> pelo
    # conteudo encontrado na tabela "Examples:", este codigo abaixo faz isto.
    # TODO contribuir de volta com o projeto, criar testes, encontrar lugar
    # no projeto Analizo para manter este trecho de código, ele não dev eficar
    # aqui
    # Ainda n sei como descobrir em qual linha do Exmaples estamos,
    # portanto por hora crio entradas no arquivo com todas as linhas do Examples
    foreach my $row (@{ $c->scenario->data }) {
      foreach my $col (keys %$row) {
        (my $data = $c->data) =~ s/<$col>/$row->{$col}/sg;
        print FILE "$data";
      }
    }
  }
  else {
    print FILE $c->data;
  }
  close FILE;
};

Given qr/^I change to an empty temporary directory$/, func($c) {
  chdir tempdir(CLEANUP => 1);
};

Given qr/^I am in (.+)$/, func($c) {
  chdir $1;
};

Then qr/^analizo must emit a warning matching "([^\"]*)"$/, func($c) {
  like($stderr, qr/$1|\Q$1\E/);
};
