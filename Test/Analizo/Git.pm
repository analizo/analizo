package Test::Analizo::Git;

use base 'Exporter';
@EXPORT = qw(
  $MASTER
  $SOME_COMMIT
  $IRRELEVANT_COMMIT
);

our $MASTER = '8183eafad3a0f3eff6e8869f1bdbfd255e86825a'; # first commit id in sample
our $SOME_COMMIT = '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed'; # some commit in the middle of the history
our $IRRELEVANT_COMMIT = 'acd043761ee8071e8cef792629ccbb9492c53132';

1;
