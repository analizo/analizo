package Analizo::Batch::Runner::Parallel;
use strict;
use warnings;
use ZeroMQ qw/:all/;
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

sub run {
  my ($self, $batch, $output) = @_;
  $self->start_workers();
  $self->coordinate_workers($batch, $output);
  $self->wait_for_workers();
  $output->flush();
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
      my $source = _socket_spec('source', $ppid);
      my $results = _socket_spec('results', $ppid);
      worker($source, $results);
      exit();
    }
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

  my $context = ZeroMQ::Context->new();

  my $workers = $context->socket(ZMQ_REP);
  $workers->bind(_socket_spec('source', $$));

  my $results = $context->socket(ZMQ_PULL);
  $results->bind(_socket_spec('results', $$));

  my $poller = ZeroMQ::Poller->new(
    {
      name      => 'job_request',
      socket    => $workers,
      events    => ZMQ_POLLIN,
    },
    {
      name      => 'results',
      socket    => $results,
      events    => ZMQ_POLLIN,
    },
  );

  my $before_each_job = $self->before_each_job || sub {};

  my $results_received = 0;
  my $workers_finished = 0;
  my $results_expected = 0;
  my $number_of_workers = $self->parallelism;
  while ($results_received < $results_expected || $workers_finished < $number_of_workers) {
    $poller->poll();
    if ($poller->has_event('job_request')) {
      $workers->recv();
      my $job = $batch->next();
      if ($job) {
        &$before_each_job($job);
        $workers->send(Dump($job));
        $results_expected++;
      } else {
        # no more jobs to process, tell workers to finish with an empty job
        $workers->send(Dump({}));
        $workers_finished++;
      }
    }
    if ($poller->has_event('results')) {
      my $msg = $results->recv();
      my $job = Load($msg->data);
      $output->push($job);
      $results_received++;
    }
  }
}

sub worker {
  my ($source_spec, $results_spec) = @_;
  my $context = ZeroMQ::Context->new();
  my $source = $context->socket(ZMQ_REQ);
  $source->connect($source_spec);
  my $results = $context->socket(ZMQ_PUSH);
  $results->connect($results_spec);
  my $run = 1;
  while ($run) {
    $source->send('');
    my $msg = $source->recv();
    my $job = Load($msg->data);
    if (exists($job->{id})) {
      $job->execute();
      $results->send(Dump($job));
    } else {
      # a job without an id means that there are no more jobs to process, we
      # should exit.
      $run = 0;
    }
  }
}

1;
