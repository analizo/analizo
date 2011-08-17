package Test::Analizo::Git;

use base 'Exporter';
@EXPORT = qw(
  $MASTER
  $SOME_COMMIT
  $IRRELEVANT_COMMIT
  $FIRST_COMMIT
  $MERGE_COMMIT
  $ADD_OUTPUT_COMMIT
);

our $MASTER = '8183eafad3a0f3eff6e8869f1bdbfd255e86825a'; # first commit id in sample
our $SOME_COMMIT = '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed'; # some commit in the middle of the history
our $IRRELEVANT_COMMIT = 'acd043761ee8071e8cef792629ccbb9492c53132';
our $FIRST_COMMIT = '0d3c023120ad4e9f519a03fff275d048c52671ad';
our $MERGE_COMMIT = '0fdaaa7dcc8073332a957024fafc8c98f165e725';
our $ADD_OUTPUT_COMMIT = 'e8faf88f0e20a193d700b6c68eeb31897dd85e53';

1;
