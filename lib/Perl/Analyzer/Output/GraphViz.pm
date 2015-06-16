package Perl::Analyzer::Output::GraphViz;
use strict;
use warnings;
use base 'Perl::Analyzer::Output::Base';
use GraphViz2;

sub new {
    my ($class, %args) = @_;
    my $self = {
        'codebase'   => $args{'codebase'},
        'output_dir' => $args{'output_dir'},
        'format'     => $args{'format'} || 'svg',
        'options'    => $args{'options'} || '',
        'opts'       => {
            rankdir => 'TB',
        }, # internal options
    };
    bless $self, $class;
    return $self;
}


sub make {
    my $self = shift;
    $self->parse_options();
    $self->create_output_dir();
    $self->build_namespace_graph();
    $self->build_package_graph();
}


sub build_namespace_graph {
    my $self = shift;

    my ($graph) = GraphViz2->new(
                 edge   => {color => 'black'},
                 global => {directed => 1},
                 graph  => {label => 'Namespaces', %{$self->{'opts'}} },
                 node   => {color => 'blue', shape => 'box'},
    );

    my $ns_tree = $self->{'codebase'}->{'namespace_tree'};
    _process_graph($graph, $ns_tree, '');

    $self->save_graph($graph, $self->{'format'}, 'namespaces');
}


sub build_package_graph {
    my $self = shift;

    my ($graph) = GraphViz2->new(
                 edge   => {color => 'black'},
                 global => {directed => 1},
                 graph  => {label => 'Packages', %{$self->{'opts'}} },
                 node   => {color => 'blue', shape => 'box'},
    );

    for my $pkg (sort keys %{$self->{'codebase'}->{'packages'}}) {
        $graph->add_node( name => $pkg );
        my $parent = $self->{'codebase'}->{'packages'}->{$pkg}->{'parent'};
        for my $p (@{$parent}) {
            $graph->add_edge( from => $p, to => $pkg ); 
        }
    }

    $self->save_graph($graph, $self->{'format'}, 'packages');
}


sub _process_graph {
    my ($graph, $ns_tree, $current_node) = @_;
    for my $ns (sort keys %{$ns_tree}) {
        $graph->add_node( name => $ns );
        if ($current_node) {
           $graph->add_edge(from => $current_node, to => $ns);
        }
        _process_graph($graph, $ns_tree->{$ns}, $ns);
    }
}


sub save_graph {
    my ($self, $graph, $format, $name) = @_;
    my $filename = $name . '.' . $format;
    $graph->run(format => $format, output_file => $self->output_file($filename));
}


1;
