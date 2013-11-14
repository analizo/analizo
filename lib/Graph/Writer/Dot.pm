#
# Graph::Writer::Dot - write a directed graph out in Dot format
#
package Graph::Writer::Dot;

use strict;
use warnings;

use parent 'Graph::Writer';
our $VERSION = '2.05';

#-----------------------------------------------------------------------
# List of valid dot attributes for the entire graph, per node,
# and per edge. You can set other attributes, but they won't get
# written out.
#-----------------------------------------------------------------------
my %valid_attributes =
(
    graph => [qw(bb bgcolor center clusterrank color comment compound
		 concentrate Damping defaultlist dim dpi epsilon fontcolor
		 fontname fontpath fontsize label labeljust labelloc layers
		 layersep lp margin maxiter mclimit mindist mode model nodesep
		 nojustify normalize nslimit nslimit1 ordering ordering
		 orientation outputorder overlap pack packmode page pagedir
		 quantum rank rankdir ranksep ratio remincross resolution
		 root rotate samplepoints searchsize sep showboxes size
		 splines start stylesheet target truecolor viewport voro_margin)],

    node  => [qw(bottomlabel color comment distortion fillcolor fixedsize
		 fontcolor fontname fontsize group height width label layer
		 margin nojustify orientation peripheries pin pos rects regular
		 root shape shapefile showboxes sides skew style target
		 tooltip toplabel URL vertices width z)],

    edge  => [qw(arrowhead arrowsize arrowtail color comment constraint decorate
		 dir fontcolor fontname fontsize headURL headclip headhref
		 headlabel headport headtarget headtooltip href id label
		 labelangle labeldistance labelfloat labelfontcolor labelfontname
		 labelfontsize layer len lhead lp ltail minlen nojustify
		 pos samehead sametail showboxes style tailURL tailclip
		 tailhref taillabel tailport tailtarget tailtooltip target
		 tooltip weight)],
);

#=======================================================================
#
# _init()
#
# class-specific initialisation. There isn't any here, but it's
# kept as a place-holder.
#
#=======================================================================
sub _init
{
    my $self = shift;
    my %param = @_;

    $self->SUPER::_init();
    $self->{_cluster} = $param{cluster};
}

#=======================================================================
#
# _write_graph()
#
# The private method which actually does the writing out in
# dot format.
#
# This is called from the public method, write_graph(), which is
# found in Graph::Writer.
#
#=======================================================================
sub _write_graph
{
    my $self  = shift;
    my $graph = shift;
    my $FILE  = shift;

    my $v;
    my $from;
    my $to;
    my $gn;
    my $attrref;
    my @keys;


    #-------------------------------------------------------------------
    # If the graph has a 'name' attribute, then we use that for the
    # name of the digraph instance. Else it's just 'g'.
    #-------------------------------------------------------------------
    $gn = $graph->has_graph_attribute('name') ? $graph->get_graph_attribute('name') : 'g';
    print $FILE "digraph $gn\n{\n";

    #-------------------------------------------------------------------
    # Dump out any overall attributes of the graph
    #-------------------------------------------------------------------
    $attrref = $graph->get_graph_attributes();
    @keys = grep(exists $attrref->{$_}, @{$valid_attributes{'graph'}});
    if (@keys > 0)
    {
        print $FILE "  /* graph attributes */\n";
        foreach my $a (@keys)
        {
            print $FILE "  $a = \"", $attrref->{$a}, "\";\n";
        }
    }

    #-------------------------------------------------------------------
    # Generate a list of nodes, with attributes for those that have any.
    #-------------------------------------------------------------------
    print $FILE "\n  /* list of nodes */\n";
    foreach $v (sort $graph->vertices)
    {
        print $FILE "  \"$v\"";
        $attrref = $graph->get_vertex_attributes($v);
        @keys = grep(exists $attrref->{$_}, @{$valid_attributes{'node'}});
        if (@keys > 0)
        {
            print $FILE " [", join(',',
                              map { "$_=\"".$attrref->{$_}."\"" } @keys), "]";
        }
        print $FILE ";\n";
    }

    if ($self->{_cluster} && grep { $_ eq $self->{_cluster} } @{$valid_attributes{'node'}}) {
        #-------------------------------------------------------------------
        # Generate a list of subgraphs based on the attribute value.
        #-------------------------------------------------------------------
        print $FILE "\n  /* list of subgraphs */\n";
        my %cluster = ();
        foreach my $v (sort $graph->vertices) {
            my $attrs = $graph->get_vertex_attributes($v);
            next unless $attrs && $attrs->{$self->{_cluster}};
            my $attr_value = $attrs->{$self->{_cluster}};
            $cluster{$attr_value} = [] unless exists $cluster{$attr_value};
            push @{ $cluster{$attr_value} }, $v;
        }
        foreach my $attr_value (sort keys %cluster) {
            print $FILE "  subgraph \"cluster_$attr_value\" {\n";
            print $FILE "    label = \"$attr_value\";\n";
            foreach my $node (@{ $cluster{$attr_value} }) {
                print $FILE "    node [label=\"$node\"] \"$node\";\n";
            }
            print $FILE "  }\n";
        }
    }

    #-------------------------------------------------------------------
    # Generate a list of edges, along with any attributes
    #-------------------------------------------------------------------
    print $FILE "\n  /* list of edges */\n";
    foreach my $edge (sort _by_vertex $graph->edges)
    {
        ($from, $to) = @$edge;
        print $FILE "  \"$from\" -> \"$to\"";
        $attrref = $graph->get_edge_attributes($from, $to);
        @keys = grep(exists $attrref->{$_}, @{$valid_attributes{'edge'}});
        if (@keys > 0)
        {
            print $FILE " [", join(',',
                              map { "$_ = \"".$attrref->{$_}."\"" } @keys), "]";
        }
        print $FILE ";\n";
    }

    #-------------------------------------------------------------------
    # close off the digraph instance
    #-------------------------------------------------------------------
    print $FILE "}\n";

    return 1;
}


sub _by_vertex
{
    return $a->[0].$a->[1] cmp $b->[0].$b->[1];
}


1;

__END__

=head1 NAME

Graph::Writer::Dot - write out directed graph in Dot format

=head1 SYNOPSIS

  use Graph;
  use Graph::Writer::Dot;
    
  $graph = Graph->new();
  # add edges and nodes to the graph
    
  $writer = Graph::Writer::Dot->new();
  $writer->write_graph($graph, 'mygraph.dot');

=head1 DESCRIPTION

B<Graph::Writer::Dot> is a class for writing out a directed graph
in the file format used by the I<dot> tool (part of the AT+T graphviz
package).
The graph must be an instance of the Graph class, which is
actually a set of classes developed by Jarkko Hietaniemi.

=head1 METHODS

=head2 new()

Constructor - generate a new writer instance.

  $writer = Graph::Writer::Dot->new();

This can take one optional argument that tell to cluster nodes in subgraphs
by using the attribute passed as value. See:

  $writer = Graph::Writer::Dot->new(cluster => 'group');

It will group nodes that have the the same value in the 'group' attribute.

=head2 write_graph()

Write a specific graph to a named file:

  $writer->write_graph($graph, $file);

The C<$file> argument can either be a filename,
or a filehandle for a previously opened file.

=head1 SEE ALSO

=over 4

=item http://www.graphviz.org/

The home page for the AT+T graphviz toolkit that
includes the dot tool.

=item Graph

Jarkko Hietaniemi's modules for representing directed graphs,
available from CPAN under modules/by-module/Graph/

=item Algorithms in Perl

The O'Reilly book which has a chapter on directed graphs,
which is based around Jarkko's modules.

=item Graph::Writer

The base-class for Graph::Writer::Dot

=back

=head1 AUTHOR

Neil Bowers E<lt>neil@bowers.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2001-2012, Neil Bowers. All rights reserved.
Copyright (c) 2001, Canon Research Centre Europe. All rights reserved.

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

