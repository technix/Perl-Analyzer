package Perl::Analyzer::Output::JSON;
use strict;
use warnings;
use base 'Perl::Analyzer::Output::Base';
use JSON;

sub new {
    my ($class, %args) = @_;
    my $self = {
        'codebase'   => $args{'codebase'},
        'output_dir' => $args{'output_dir'},
    };
    $self->{'json'}         = JSON->new();
    bless $self, $class;
    return $self;
}


sub make {
    my $self = shift;
    $self->create_output_dir();
    $self->dump_codebase();
}


sub dump_codebase {
    my $self = shift;
    foreach my $type (sort keys $self->{'codebase'}) {
        my $filename  = $self->output_file($type . '.json');
        my $json_data = $self->{'json'}->pretty->encode( $self->{'codebase'}->{$type} );
        $self->save_file($filename, $json_data);
    }
}

1;
