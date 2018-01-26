package t::Analizo::Command;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;
use Test::Exception;

BEGIN {
  use_ok 'Analizo::Command'
};

sub any_command_is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('fake');
  isa_ok($cmd, 'Analizo::Command');
}

sub version_information : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('fake');
  like($cmd->version_information, qr/^\S+ version \d+\.\d+\.\d+(~rc\d+)?$/);
}

sub execute_some_command : Tests {
  my $analizo = Analizo->new;
  my $return = $analizo->execute_command( $analizo->prepare_command('fake') );
  is($return, "command fake executed");
}

sub executing_commands_with_version_argument_is_not_allowed : Tests {
  my $analizo = Analizo->new;
  throws_ok {
    $analizo->execute_command( $analizo->prepare_command('fake', '--version') )
  } qr /Invalid option/;
}

__PACKAGE__->runtests;

package t::Analizo::Command::fake;
use Analizo -command;
use base qw(Analizo::Command);
sub validate {}
sub execute { "command fake executed" }
1;
