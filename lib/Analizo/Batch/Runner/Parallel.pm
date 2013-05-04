package Analizo::Batch::Runner::Parallel;
use strict;
use warnings;
use ZMQ::LibZMQ2;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL ZMQ_REQ ZMQ_REP);
use YAML;

use base qw( Analizo::Batch::Runner );

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

  my $context = zmq_init();

  my $queue = zmq_socket($context, ZMQ_PUSH);
  zmq_bind($queue, _socket_spec('queue', $$));

  my $results = zmq_socket($context, ZMQ_PULL);
  zmq_bind($results, _socket_spec('results', $$));

  # push jobs to queue
  my $results_expected = 0;
  while (my $job = $batch->next()) {
    zmq_send($queue, Dump($job));
    $results_expected++;
  }
  zmq_send($queue, Dump({}));

  # collect results
  my $results_received = 0;
  while ($results_received < $results_expected) {
    my $msg = zmq_recv($results);
    my $job = Load(zmq_msg_data($msg));
    $output->push($job);
    $results_received++;
    $self->report_progress($job, $results_received, $results_expected);
  }
}

sub distributor {
  my ($parent_pid, $number_of_workers) = @_;
  my $context = zmq_init();

  my $queue = zmq_socket($context, ZMQ_PULL);
  zmq_connect($queue, _socket_spec('queue', $parent_pid));

  my $job_source = zmq_socket($context, ZMQ_REP);
  zmq_bind($job_source, _socket_spec('job_source', $parent_pid));

  my @queue;
  my $job;
  while(1) {
    my $msg = zmq_recv($queue);
    $job = Load(zmq_msg_data($msg));
    last if !exists($job->{id});
    push(@queue, $job);
  }

  my $workers_finished = 0;
  while ($workers_finished < $number_of_workers) {
    zmq_recv($job_source);
    if(scalar(@queue) > 0) {
      $job = shift(@queue);
      zmq_send($job_source, Dump($job));
    } else {
      zmq_send($job_source, Dump({}));
      $workers_finished++;
    }
  }
}

sub worker {
  my ($parent_pid) = @_;
  my $context = zmq_init();
  my $source = zmq_socket($context, ZMQ_REQ);
  zmq_connect($source, _socket_spec('job_source', $parent_pid));
  my $results = zmq_socket($context, ZMQ_PUSH);
  zmq_connect($results, _socket_spec('results', $parent_pid));
  my $run = 1;
  my $last_job = undef;
  while ($run) {
    zmq_send($source, '');
    my $msg = zmq_recv($source);
    my $job = Load(zmq_msg_data($msg));
    if (exists($job->{id})) {
      $last_job = $job;
      $job->parallel_prepare();
      $job->execute();
      zmq_send($results, Dump($job));
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
