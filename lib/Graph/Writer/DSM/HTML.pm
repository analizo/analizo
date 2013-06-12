package Graph::Writer::DSM::HTML;
use Modern::Perl;
use base qw( Graph::Writer );

use Mojo::Template;

use vars qw( $TEMPLATE );
INIT {
  my @template = <DATA>;
  $TEMPLATE = join('', @template);
}

=head1 NAME

=cut

sub _init {
  my ($self, %param) = @_;
  $self->SUPER::_init();
  $self->{_title} = $param{title};
}

sub _write_graph {
  my ($self, $graph, $FILE) = @_;
  my $template = Mojo::Template->new;
  my $output = $template->render($TEMPLATE, $graph, $self->{_title});
  print $FILE $output;
}

1;


__DATA__
% my ($graph, $title) = @_;
% $title ||= 'Design Structure Matrix';
% my @modules = sort($graph->vertices);
<!DOCTYPE html>
<html>
  <body>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf8"/>
      <title><%= $title %></title>
      <style type="text/css">
        table {
          border-collapse: collapse;
        }
        th {
          background: #eeeeec;
        }
        td, th {
          border: 1px solid #d3d7cf;
          min-width: 20px;
          text-align: center;
          vertical-align: center;
        }
        th:first-child {
          text-align: right;
          padding: 0px 5px;
        }
        td.empty {
          border: none;
        }
      </style>
    </head>
    <h1><%= $title %></h1>
    <table>
      <tr>
        <td class='empty'></td>
        % foreach my $m (@modules) {
        <th title='<%= $m %>'>&nbsp;</th>
        % }
      </tr>
      % foreach my $m1 (@modules) {
      <tr>
        <th><%= $m1 %></th>
        % foreach my $m2 (@modules) {
          % if ($m1 eq $m2) {
            <th title='<%= $m1 %>'>&nbsp;</th>
          % }
          % elsif ($graph->has_edge($m1, $m2)) {
            <td class='dependency' title='<%= $m1 %> &rarr; <%= $m2 %>'>&#9679;</td>
          % } else {
            <td>&nbsp;</td>
          % }
        % }
      </tr>
      % }
    </table>
  </body>
</html>
