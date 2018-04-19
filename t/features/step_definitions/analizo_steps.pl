use strict;
use warnings;
use Test::More;
use Test::BDD::Cucumber::StepFile;
use File::Slurp;
use File::Temp qw( tempdir );
use File::Copy::Recursive qw( rcopy );
use YAML::XS;
use File::LibMagic;
use Archive::Extract;
use DBI;
use File::Spec;

our $exit_status;
our $stdout;
our $stderr;

use Env qw(@PATH $PWD);
push @PATH, "$PWD/blib/script", "$PWD/bin";

use IPC::Open3;
use Symbol 'gensym';

When qr/^I run "([^\"]*)"$/, sub {
  my ($c) = @_;
  my $command = $1;
  my ($IN, $STDOUT, $STDERR);
  $STDERR = gensym;
  my $pid = open3($IN, $STDOUT, $STDERR, "$command 2>tmp.err");
  waitpid $pid, 0;
  $exit_status = $?;
  local $/ = undef;
  $stdout = <$STDOUT>;
  $stderr = <$STDERR> . read_file('tmp.err');
};

When qr/^I run "([^\"]*)" on database "([^\"]*)"$/, sub {
  my ($c) = @_;
  my $statement = $1;
  my $db = $2;
  my @a = DBI->connect("dbi:SQLite:$db")->selectall_array($statement);
  $stdout = join("\n", map { join("|", @$_) } @a), "\n";
};

Then qr/^the output must match "([^\"]*)"$/, sub {
  my ($c) = @_;
  like($stdout, qr/$1|\Q$1\E/);
};

Then qr/^the output must not match "([^\"]*)"$/, sub {
  my ($c) = @_;
  unlike($stdout, qr/$1|\Q$1\E/);
};

Then qr/^the exit status must be (\d+)$/, sub {
  my ($c) = @_;
  cmp_ok($exit_status, '==', $1);
};

Then qr/^the exit status must not be (\d+)$/, sub {
  my ($c) = @_;
  cmp_ok($exit_status, '!=', $1);
};

Step qr/^I copy (.*) into a temporary directory$/, sub {
  my ($c) = @_;
  my $tmpdir = tempdir("analizo-XXXXXXXXXX", CLEANUP => 1, DIR => File::Spec->tmpdir);
  rcopy($1, $tmpdir);
  chdir $tmpdir;
};

Given qr/^I create a file called (.+) with the following content$/, sub {
  my ($c) = @_;
  open FILE, '>', $1 or die $!;
  if ($c->data =~ m/<\w+>/) {
    # The Test::BDD::Cucumber not support replace strings <key> in the content
    # by the values in table "Examples:", the code above does this.
    # Not yet know how find out what line of "Examples:" we are, then for now
    # we create entries for all values in the table.
    # TODO Implement it on Test::BDD::Cucumber in the right way and contribute
    # back to upstream.
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

Given qr/^I change to an empty temporary directory$/, sub {
  my ($c) = @_;
  chdir tempdir("analizo-XXXXXXXXXX", CLEANUP => 1, DIR => File::Spec->tmpdir);
};

Given qr/^I am in (.+)$/, sub {
  my ($c) = @_;
  chdir $1;
};

Then qr/^analizo must emit a warning matching "([^\"]*)"$/, sub {
  my ($c) = @_;
  like($stderr, qr/$1|\Q$1\E/);
};

Then qr/^analizo must not emit a warning matching "([^\"]*)"$/, sub {
  my ($c) = @_;
  unlike($stderr, qr/$1|\Q$1\E/);
};

Then qr/^analizo must report that "([^\"]*)" is part of "([^\"]*)"$/, sub {
  my ($c) = @_;
  my ($func, $mod) = ($1, $2);
  like($stdout, qr/subgraph "cluster_$mod" \{[^}]*node[^}]*"\Q$func\E";/);
};

Then qr/^analizo must report that "([^\"]*)" depends on "([^\"]*)"$/, sub {
  my ($c) = @_;
  my ($dependent, $depended) = ($1, $2);
  like($stdout, qr/"\Q$dependent\E" -> "\Q$depended\E"/);
};

Then qr/^the contents of "(.+)" must match "([^\"]*)"$/, sub {
  my ($c) = @_;
  my ($file, $pattern) = ($1, $2);
  like(read_file($file), qr/$pattern/);
};

Then qr/^analizo must report that the project has (.+) = ([\d\.]+)$/, sub {
  my ($c) = @_;
  my ($metric, $n) = ($1, $2);
  my @stream = Load($stdout);
  cmp_ok($stream[0]->{$metric}, '==', $n);
};

Then qr/^analizo must report that module (.+) has (.+) = (.+)$/, sub {
  my ($c) = @_;
  my ($module, $metric, $value) = ($1, $2, $3);
  my @stream = Load($stdout);
  my ($module_metrics) = grep { $_->{_module} && $_->{_module} eq $module } @stream;
  if ($module_metrics->{$metric}) {
    if ($value =~ /^\d+|\d+\.\d+$/) {
      cmp_ok($module_metrics->{$metric}, '==', $value);
    }
    elsif ($value =~ /^\[(.*)\]$/) {
      my @values = split(/\s*,\s*/, $1);
      is_deeply($module_metrics->{$metric}, \@values);
    }
  }
};

Then qr/^analizo must report that file (.+) not declares module (.+)$/, sub {
  my ($c) = @_;
  my ($filename, $module) = ($1, $2);
  my @stream = Load($stdout);
  my ($document) = grep { $_->{_module} && $_->{_module} eq $module } @stream;
  ok(!grep { /^$filename$/ } @{$document->{_filename}});
};

Then qr/^analizo must report that file (.+) declares module (.+)$/, sub {
  my ($c) = @_;
  my ($filename, $module) = ($1, $2);
  my @stream = Load($stdout);
  my ($document) = grep { $_->{_module} && $_->{_module} eq $module } @stream;
  ok(grep { /^$filename$/ } @{$document->{_filename}});
};

Then qr/^analizo must present a list of metrics$/, sub {
  my ($c) = @_;
  like($stdout, qr/Global Metrics:/);
  like($stdout, qr/Module Metrics:/);
};

Then qr/^analizo must present a list of languages$/, sub {
  my ($c) = @_;
  like($stdout, qr/Languages:/);
};

Then qr/^the file "([^\"]*)" should exist$/, sub {
  my ($c) = @_;
  my $file = $1;
  ok(-e $file);
};

Then qr/^the file "([^\"]*)" should not exist$/, sub {
  my ($c) = @_;
  my $file = $1;
  ok(! -e $file);
};

Then qr/^the file "(.*?)" should have type (.*)$/, sub {
  my ($c) = @_;
  my ($file, $type) = ($1, $2);
  my $magic = File::LibMagic->new;
  my $mime = $magic->checktype_filename($file);
  like($mime, qr/$type;/);
};

When qr/^I explode (.+)$/, sub {
  my ($c) = @_;
  my $tarball = $1;
  my $archive = Archive::Extract->new(archive => $tarball);
  $archive->extract(to => tempdir("analizo-XXXXXXXXXX", CLEANUP => 1, DIR => File::Spec->tmpdir));
  chdir $archive->extract_path;
};

Then qr/^the output lines must match "([^\"]*)"$/, sub {
  my ($c) = @_;
  my $pattern = $1;
  like($stdout, qr/$pattern/);
};
