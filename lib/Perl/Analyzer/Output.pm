package Perl::Analyzer::Output;
use strict;
use warnings;
use Storable;

sub new {
    my ($class, %args) = @_;
    my $self = {
        'output' => {
            'dump' => 'Perl::Analyzer::Output::Dumper',
            'json' => 'Perl::Analyzer::Output::JSON',
            'html' => 'Perl::Analyzer::Output::HTML',
            'dot'  => 'Perl::Analyzer::Output::GraphViz',
            'svg'  => 'Perl::Analyzer::Output::GraphViz',
            'png'  => 'Perl::Analyzer::Output::GraphViz',
        },
        codebase => $args{'codebase'},
    };
    bless $self, $class;
    return $self;
}


sub formats {
    my $self = shift;
    return sort keys %{$self->{'output'}};
}


sub from_file {
    my ($self, $filename) = @_;
    $self->{'codebase'} = retrieve($filename) or die $!;
    return 1;
}


sub apply_filter {
    my ($self, $filter_re) = @_;
    return if ! $self->{'codebase'};
    
    my $filter = $filter_re || '.*';
    my $filter_regexp = qr($filter);

    for my $pkg (keys %{$self->{'codebase'}->{'packages'}}) {
        _package_ref_filter( $self->{'codebase'}->{'packages'}->{$pkg}, $filter_regexp );
    }
    
    return 1;
}


sub _package_ref_filter {
    my ($pkg_ref, $filter) = @_;
    $pkg_ref->{'depends_on'} = [ sort grep( /$filter/, @{$pkg_ref->{'depends_on'}}) ];
    $pkg_ref->{'parent'}     = [ sort grep( /$filter/, @{$pkg_ref->{'parent'}}) ];
}


sub render {
    my ($self, %args) = @_;
    # format, output_dir
    my $output = $self->{'output'}->{$args{'format'}};
    (my $require_name = $output . ".pm") =~ s{::}{/}g;
    require $require_name;
    my $renderer = $output->new(codebase => $self->{'codebase'}, %args);
    $renderer->make();
}


1;
