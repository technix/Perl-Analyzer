package Perl::Analyzer::Output::Dumper;
use strict;
use warnings;
use base 'Perl::Analyzer::Output::Base';
use Data::Dumper;

sub new {
    my ($class, %args) = @_;
    my $self = {
        'codebase'   => $args{'codebase'},
        'output_dir' => $args{'output_dir'},
    };
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
    foreach my $type (sort keys %{ $self->{'codebase'} }) {
        my $filename  = $self->output_file($type . '.dump');
        my $data = Dumper($self->{'codebase'}->{$type});
        $self->save_file($filename, $data);
    }
}

1;
