package t::Analizo::Batch::Job::Git;
use strict;
use warnings;
use parent qw(Test::Analizo::Class);
use Test::More;
use Test::Analizo;
use Cwd;
use File::Basename;
use Test::MockObject;
use Test::Analizo::Git;

use Analizo::Batch::Job::Git;
use Analizo::Batch::Git;

my $TESTDIR = 'evolution';


sub constructor : Tests {
  isa_ok(Analizo::Batch::Job::Git->new, 'Analizo::Batch::Job::Git');
}

sub constructor_with_arguments : Tests {
  my $id = $MASTER;
  my $job = Analizo::Batch::Job::Git->new($TESTDIR, $id);
  is($job->directory, $TESTDIR);
  is($job->{actual_directory}, $TESTDIR);
  is($job->id, $id);
}

sub parallelism_support : Tests {
  my $job = __find($MASTER);
  $job->parallel_prepare();

  isnt($job->{actual_directory}, $TESTDIR);
  ok(-d $job->{actual_directory}, "different work directory must be created");
  ok(-d File::Spec->catfile($job->{actual_directory}, '.git'), "content must be copied");

  $job->parallel_cleanup();
  ok(! -d $job->{actual_directory}, "different work directory must be removed when parallel_cleanup is called.");

  is($job->project_name, basename($TESTDIR), 'parallelism support must not mess with project name');
}

sub prepare_and_cleanup : Tests {
  my $job = mock(__find($SOME_COMMIT));

  my @checkouts = ();
  $job->mock('git_checkout', sub { push @checkouts, $_[1]; } );
  my $oldcwd = getcwd();
  $job->prepare();
  my $newcwd = getcwd();
  $job->cleanup();

  ok($newcwd ne $oldcwd, 'prepare must change dir');
  ok(getcwd eq $oldcwd, 'cleanup must change cwd back');
  is_deeply(\@checkouts, [$SOME_COMMIT, 'master'], 'cleanup must checkout given commit and go back to previous one');
}

sub git_checkout_should_actually_checkout : Tests {
  my $job = __find($SOME_COMMIT);
  my $getHEAD = sub {
    my $commit = `git log --format=%H | head -n 1`; chomp($commit);
    return $commit;
  };
  my $master1 = on_dir($TESTDIR, $getHEAD);
  $job->prepare();
  my $commit = on_dir($TESTDIR, $getHEAD);
  $job->cleanup();
  my $master2 = on_dir($TESTDIR, $getHEAD);
  my $branch = on_dir($TESTDIR, sub { $job->git_current_branch() });

  is($commit, $SOME_COMMIT);
  is($master1, $master2);
  is($master2, $MASTER);
  is($branch, 'master');
}

sub must_NOT_keep_a_reference_to_batch : Tests {
  my $batch = __get_repo();
  my $job = __find();
  $job->batch($batch);
  ok(!exists($job->{batch}));
}

sub changed_files : Tests {
  my $repo = __get_repo();

  my $master = $repo->find($MASTER);
  is_deeply($master->changed_files, {'input.cc' => 'M'});

  my $some_commit = $repo->find($SOME_COMMIT);
  is_deeply($some_commit->changed_files, {'prog.cc' => 'M'});

  my $add_output_commit = $repo->find($ADD_OUTPUT_COMMIT);
  is_deeply($add_output_commit->changed_files, { 'output.cc' => 'A', 'output.h' => 'A', 'prog.cc' => 'M' });

  my $relevant_merge_commit = $repo->find($RELEVANT_MERGE);
  is_deeply($relevant_merge_commit->changed_files, { 'prog.cc' => 'MM' });
}

sub previous_relevant : Tests {
  my $batch = __get_repo();

  my $first = $batch->find($FIRST_COMMIT);
  is($first->previous_relevant, undef);

  my $master = $batch->find($MASTER);
  is($master->previous_relevant, '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed');

  my $commit = $batch->find('0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed');
  is($commit->previous_relevant, 'eb67c27055293e835049b58d7d73ce3664d3f90e');
}

sub previous_relevant_with_parent_without_previous_relevant : Tests {
  my $repo = __get_repo('foo');
  my $job = $repo->find('874073a5a36004cf26794a7ff2eacf496f29b786');
  is($job->previous_relevant, undef, 'must return undef as previous_relevant when parent is a merge commit without any previous relevant commits');
}

sub relevant_merge : Tests {
  my $batch = __get_repo();
  my $relevant_merge = $batch->find($RELEVANT_MERGE);
  ok($relevant_merge->relevant());
}

sub previous_wanted : Tests {
  my $batch = __get_repo();

  my $master = $batch->find($MASTER);
  is($master->previous_wanted, $master->previous_relevant);

  my $merge = $batch->find($MERGE_COMMIT);
  is($merge->previous_wanted, undef);
}

sub metadata : Tests {
  my $repo = __get_repo();
  my $master = $repo->find($MASTER);

  my $metadata = $master->metadata();
  metadata_ok($metadata, 'author_name', 'Antonio Terceiro', 'author name');
  metadata_ok($metadata, 'author_email', 'terceiro@softwarelivre.org', 'author email');
  metadata_ok($metadata, 'author_date', 1297788040, 'author date'); # UNIX timestamp for [Tue Feb 15 13:40:40 2011 -0300]
  metadata_ok($metadata, 'previous_commit_id', '0a06a6fcc2e7b4fe56d134e89d74ad028bb122ed', 'previous commit');
  metadata_ok($metadata, 'changed_files', {'input.cc' => 'M'}, 'changed files');

  my @files_entry = grep { $_->[0] eq 'files' } @$metadata;
  my $files = $files_entry[0]->[1];

  is($files->{'input.cc'},   '0e85dc55b30f5e257ce5615bfcb229d1ace13e01');
  is($files->{'input.h'},    '44edccb29f8b8ba252f15988edacfad481606c45');
  is($files->{'output.cc'},  'ed526e137858cb903730a1886db430c28d6bebcf');
  is($files->{'output.h'},   'a67e1b0986b9cab18fbbb12d0f941982c74d724d');
  is($files->{'prog.cc'},    '91745088e303c9440b6d58a5232b5d753d3c91f5');
  ok(!defined($files->{Makefile}), 'must not include non-code files in tree');

  my $first = $repo->find($FIRST_COMMIT);
  metadata_ok($first->metadata, 'previous_commit_id', undef, 'unexisting commit id');
}

sub merge_and_first_commit_detection : Tests {
  my $repo = __get_repo();
  my $master = $repo->find($MASTER);
  ok(!$master->is_merge);
  ok(!$master->is_first_commit);

  my $first = $repo->find($FIRST_COMMIT);
  ok($first->is_first_commit);

  my $merge = $repo->find($MERGE_COMMIT);
  ok($merge->is_merge);
}

sub metadata_ok {
  my ($metadata,$field,$value,$testname) = @_;
  if (is(ref($metadata), 'ARRAY', $testname))  {
    my @entries = grep { $_->[0] eq $field } @$metadata;
    my $entry = $entries[0];
    if (is(ref($entry), 'ARRAY', $testname)) {
      is_deeply($entry->[1], $value, $testname);
    }
  }
}

sub __find {
  my ($id) = @_;
  if (defined($id)) {
    my $repo = __get_repo();
    return $repo->find($id);
  } else {
    return Analizo::Batch::Job::Git->new;
  }
}

my %REPOS = ();
sub __get_repo {
  my ($repoid) = @_;
  $repoid ||= $TESTDIR;
  if (defined($REPOS{$repoid})) {
    return $REPOS{$repoid};
  }
  my $repo = Analizo::Batch::Git->new($repoid);
  $repo->initialize();
  $REPOS{$repoid} = $repo;
  return $repo;
}

unpack_sample_git_repository(
  sub {
    my $cwd = getcwd;
    chdir tmpdir();
    __PACKAGE__->runtests;
    chdir $cwd;
  },
  'evolution',
  'foo'
);
