package Analizo::Batch::Runner::Parallel;
use strict;
use warnings;
use ZMQ::FFI qw(ZMQ_PUSH ZMQ_PULL ZMQ_REQ ZMQ_REP);
use YAML::XS;

use parent qw( Analizo::Batch::Runner );

$YAML::XS::LoadBlessed = 1;
$YAML::XS::LoadCode = 1;
$YAML::XS::DumpCode = 1;

sub new {
  my ($class, $parallelism) = @_;
  $parallelism ||= 2;
  $class->SUPER::new(parallelism => $parallelism);
}

sub parallelism {
  my ($self) = @_;
  return $self->{parallelism};
}

sub actually_run {
  my ($self, $batch, $output) = @_;
  $self->start_workers();
  $self->coordinate_workers($batch, $output);
  $self->wait_for_workers();
}

sub _socket_spec {
  my ($name, $ppid) = @_;
  return "ipc:///tmp/.analizo-$name-$ppid";
}

sub start_workers {
  my ($self) = @_;
  $self->{workers} = [];
  my $n = $self->parallelism();
  my $ppid = $$;
  for my $i (1..$n) {
    my $pid = fork();
    if ($pid) {
      # on parent
      push(@{$self->{workers}}, $pid);
    } else {
      # on child
      $0 = '[analizo worker]';
      worker($ppid);
      exit();
    }
  }
  my $distributor_pid = fork();
  if ($distributor_pid) {
    push(@{$self->{workers}}, $distributor_pid);
  } else {
    $0 = '[analizo queue]';
    distributor($ppid, $n);
    exit();
  }
}

sub wait_for_workers {
  my ($self) = @_;
  for my $pid (@{$self->{workers}}) {
    waitpid($pid, 0);
  }
}

sub coordinate_workers {
  my ($self, $batch, $output) = @_;

  my $context = ZMQ::FFI->new();

  my $queue = $context->socket(ZMQ_PUSH);
  $queue->bind(_socket_spec('queue', $$));

  my $results = $context->socket(ZMQ_PULL);
  $results->bind(_socket_spec('results', $$));

  # push jobs to queue
  my $results_expected = 0;
  while (my $job = $batch->next()) {
    $queue->send(Dump($job));
    $results_expected++;
  }
  $queue->send(Dump({}));

  # collect results
  my $results_received = 0;
  while ($results_received < $results_expected) {
    my $msg = $results->recv();
    my $job = Load($msg);
    $output->push($job);
    $results_received++;
    $self->report_progress($job, $results_received, $results_expected);
  }
}

sub distributor {
  my ($parent_pid, $number_of_workers) = @_;
  my $context = ZMQ::FFI->new();

  my $queue = $context->socket(ZMQ_PULL);
  $queue->connect(_socket_spec('queue', $parent_pid));

  my $job_source = $context->socket(ZMQ_REP);
  $job_source->bind(_socket_spec('job_source', $parent_pid));

  my @queue;
  my $job;
  while(1) {
    my $msg = $queue->recv();
    $job = Load($msg);
    last if !exists($job->{id});
    push(@queue, $job);
  }

  my $workers_finished = 0;
  while ($workers_finished < $number_of_workers) {
    $job_source->recv();
    if(scalar(@queue) > 0) {
      $job = shift(@queue);
      $job_source->send(Dump($job));
    } else {
      $job_source->send(Dump({}));
      $workers_finished++;
    }
  }
}

sub worker {
  my ($parent_pid) = @_;
  my $context = ZMQ::FFI->new();
  my $source = $context->socket(ZMQ_REQ);
  $source->connect(_socket_spec('job_source', $parent_pid));
  my $results = $context->socket(ZMQ_PUSH);
  $results->connect(_socket_spec('results', $parent_pid));
  my $run = 1;
  my $last_job = undef;
  while ($run) {
    $source->send('');
    my $msg = $source->recv();
    my $job = Load($msg);
    if (exists($job->{id})) {
      $last_job = $job;
      $job->parallel_prepare();
      $job->execute();
      $results->send(Dump($job));
    } else {
      # a job without an id means that there are no more jobs to process, we
      # should exit.
      $run = 0;
    }
  }
  if ($last_job) {
    $last_job->parallel_cleanup();
  }
}

1;
