package t::Analizo;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More;
use t::Analizo::Test;

BEGIN {
  use_ok 'Analizo'
};

sub constructor: Tests {
  my $analizo = Analizo->new;
  isa_ok($analizo, 'Analizo');
  isa_ok($analizo, 'App::Cmd');
}

sub load_config_file : Tests {
  my $analizo = Analizo->new;
  on_tmpdir(sub {
    open CONFIG, '>', '.analizo';
    print CONFIG 'metrics: --language java', "\n";
    close CONFIG;
    my $config = $analizo->config;
    is_deeply($config, {metrics => '--language java'});
  });
}

sub empty_hash_when_no_config_file : Tests {
  my $analizo = Analizo->new;
  my $config = $analizo->config;
  is_deeply($config, {});
}

sub load_command_options : Tests {
  my $analizo = Analizo->new;
  on_tmpdir(sub {
    open CONFIG, '>', '.analizo';
    print CONFIG 'graph: --cluster -o file.dot', "\n";
    close CONFIG;
    my @options = $analizo->load_command_options('graph');
    is_deeply(\@options, ['--cluster', '-o', 'file.dot']);
  });
}

sub empty_array_for_command_with_no_options : Tests {
  my $analizo = Analizo->new;
  on_tmpdir(sub {
    open CONFIG, '>', '.analizo';
    print CONFIG 'metrics: --language java', "\n";
    close CONFIG;
    my @options = $analizo->load_command_options('graph');
    is_deeply(\@options, []);
  });
}

__PACKAGE__->runtests;
