use strict;
use warnings;
use Test::More 'no_plan';
use Test::BDD::Cucumber::StepFile;
use Method::Signatures;
use Cwd;
use File::Slurp;
use File::Temp qw( tempdir );
use File::Copy::Recursive qw( rcopy );
use YAML::Tiny;
use feature "switch";
use File::LibMagic;
use Archive::Extract;

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

Then qr/^analizo must report that "([^\"]*)" is part of "([^\"]*)"$/, func($c) {
  my ($func, $mod) = ($1, $2);
  like($stdout, qr/subgraph "cluster_$mod" \{[^}]*node[^}]*"\Q$func\E";/);
};

Then qr/^analizo must report that "([^\"]*)" depends on "([^\"]*)"$/, func($c) {
  my ($dependent, $depended) = ($1, $2);
  like($stdout, qr/"\Q$dependent\E" -> "\Q$depended\E"/);
};

Then qr/^the contents of "(.+)" must match "([^\"]*)"$/, func($c) {
  my ($file, $pattern) = ($1, $2);
  like(read_file($file), qr/$pattern/);
};

Then qr/^analizo must emit a warning matching "([^\"]*)"$/, func($c) {
  my $pattern = $1;
  like($stderr, qr/$pattern/);
};

Then qr/^analizo must report that the project has (.+) = ([\d\.]+)$/, func($c) {
  my ($metric, $n) = ($1, $2);
  my $stream = YAML::Tiny->read_string($stdout);
  cmp_ok($stream->[0]->{$metric}, '==', $n);
};

Then qr/^analizo must report that module (.+) has (.+) = (.+)$/, func($c) {
  my ($module, $metric, $value) = ($1, $2, $3);
  my $stream = YAML::Tiny->read_string($stdout);
  my ($module_metrics) = grep { $_->{_module} && $_->{_module} eq $module } @$stream;
  for ($value) {
    when (/^\d+|\d+\.\d+$/) {
      cmp_ok($module_metrics->{$metric}, '==', $value);
    }
    when (/^\[(.*)\]$/) {
      my @values = split(/\s*,\s*/, $1);
      is_deeply($module_metrics->{$metric}, \@values);
    }
  }
};

Then qr/^analizo must present a list of metrics$/, func($c) {
  like($stdout, qr/Global Metrics:/);
  like($stdout, qr/Module Metrics:/);
};

Then qr/^analizo must present a list of languages$/, func($c) {
  like($stdout, qr/Languages:/);
};

Then qr/^the file "([^\"]*)" should exist$/, func($c) {
  my $file = $1;
  ok(-e $file);
};

Then qr/^the file "(.*?)" should have type (.*)$/, func($c) {
  my ($file, $type) = ($1, $2);
  my $magic = File::LibMagic->new;
  my $mime = $magic->checktype_filename($file);
  like($mime, qr/$type;/);
};

When qr/^I explode (.+)$/, func($c) {
  my $tarball = $1;
  my $archive = Archive::Extract->new(archive => $tarball);
  $archive->extract(to => tempdir(CLEANUP => 1));
  chdir $archive->extract_path;
};

Then qr/^the output lines must match "([^\"]*)"$/, func($c) {
  my $pattern = $1;
  like($stdout, qr/$pattern/);
};
