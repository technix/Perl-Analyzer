package Perl::Analyzer::Output::HTML;
use strict;
use warnings;
use base 'Perl::Analyzer::Output::Base';
use File::Basename;
use File::Find;
use File::Spec;
use File::Copy;
use Text::MicroTemplate qw(:all);
use Text::MicroTemplate::File;
use JSON;


sub new {
    my ($class, %args) = @_;
    # output_dir, template_dir, assets_dir, codebase
    my (undef, $location, undef) = fileparse(__FILE__);
    my $default_template_dir = File::Spec->catfile($location, 'templates');
    my $default_assets_dir = File::Spec->catfile($location, 'assets');
    my $self = {
        'codebase'   => $args{'codebase'},
        'output_dir' => $args{'output_dir'},
        'verbose'    => $args{'verbose'},
    };
    $self->{'template_dir'} = $args{'template_dir'} || $default_template_dir;
    $self->{'assets_dir'}   = $args{'assets_dir'} || $default_assets_dir;
    $self->{'json'}         = JSON->new();
    $self->{'mtf'}          = Text::MicroTemplate::File->new( include_path => [$self->{'template_dir'} ] );
    bless $self, $class;
    return $self;
}


sub make {
    my $self = shift;
    $self->create_output_dir();
    $self->copy_assets();
    $self->build_package_pages();
    $self->build_namespace_pages();
}


sub copy_assets {
    my $self = shift;
    my $copy_file = sub {
        return if -d $_;
        copy( $_, $self->{'output_dir'} );
    };
    find( $copy_file, $self->{'assets_dir'} );
}


sub build_package_pages {
    my $self = shift;
    
    my @packages = keys %{$self->{'codebase'}->{'packages'}};
    my $numpkg = scalar @packages;
    my $currpkg = 1;
    $self->progress_set(0);
    $self->debug("Building package pages");
    
    for my $pkg (@packages) {
        my ($tree, $sizes) = $self->render_dependency_json($pkg);
        $self->render_package_page({
            'package'                => $pkg,
            'data'                   => $self->{'codebase'}->{'packages'},
            'inheritance_tree_json'  => encoded_string($tree),
            'inheritance_tree_sizes' => $sizes,
        });
        
        if ($self->{'verbose'}) {
            $self->progress_counter($numpkg, $currpkg);
        }
        $currpkg++;
    }
    $self->debug("Done.");
}


sub build_namespace_pages {
    my $self = shift;
    $self->debug("Building namespace pages");
    
    my $tree = $self->{'codebase'}->{'namespace_tree'};
    my @namespaces = sort keys %{$tree};
    $self->make_namespace_index(\@namespaces, $tree);
    
    $self->debug("Done.");
}


sub make_namespace_index {
    my $self = shift;
    my ($namespaces, $tree, $current_namespace, $parent_namespace) = @_;
    my $namespace = $current_namespace || '';
    $self->render_namespace_page({
        'namespace'        => $namespace,
        'parent_namespace' => $parent_namespace || '',
        'namespaces'       => $namespaces,
        'packages'         => $self->{'codebase'}->{'namespaces'}->{$namespace} || [],
    });

    foreach my $ns (@{$namespaces}) {
        my @ns_list = sort keys($tree->{$ns});
        $self->make_namespace_index(\@ns_list, $tree->{$ns}, $ns, $namespace);
    }
}


sub render_dependency_json {
    my ($self, $package) = @_;
    my @packages = reverse @{$self->{'codebase'}->{'packages'}->{$package}->{'parent_list'}};
    my $parent_pkg = '';
    
    my $deptree = [];
    
    my $sizes = {
        maxlength => 1,
        maxchild => 1,
        depth => scalar @packages,
    };
    
    my $tree = $deptree; # we will populate it recursively
    foreach my $pkg (@packages) {
        my $mdata = {
            'name'     => $pkg,
            'parent'   => $parent_pkg || 'null',
            'type'     => $pkg eq $package ? 'node_current' : 'node_parent',
            'children' => [],
        };
        if (exists $self->{'codebase'}->{'packages'}->{$pkg}) {
            for my $use_pkg (@{$self->{'codebase'}->{'packages'}->{$pkg}->{'depends_on'}}) {
                push @{$mdata->{'children'}}, { 'name' => $use_pkg, 'parent' => $pkg, 'type' => 'node_use' };
            }
        }

        my $ml = length($pkg);
        my $mc = scalar(@{$mdata->{'children'}}) + $sizes->{'depth'};
        $sizes->{'maxlength'} = $ml if $ml > $sizes->{'maxlength'};
        $sizes->{'maxchild'}  = $mc if $mc > $sizes->{'maxchild'};

        push @{$tree}, $mdata;
        $tree = $mdata->{'children'};
        $parent_pkg = $pkg;
    }
    
    return ($self->{'json'}->encode($deptree), $sizes);
}


sub render_package_page {
    my ($self, $stash) = @_;
    my $content = $self->{'mtf'}->render_file('package.tpl', $stash);
    my $filename = _pkg_filename($stash->{'package'});
    $self->save_file($self->output_file($filename), $content);
}


sub render_namespace_page {
    my ($self, $stash) = @_;
    my $content = $self->{'mtf'}->render_file('namespace.tpl', $stash);
    my $filename = _ns_filename($stash->{'namespace'});
    $self->save_file($self->output_file($filename), $content);
}


sub _pkg_filename {
    my $pkg = shift;
    (my $filename = $pkg . ".html") =~ s/::/-/g;
    return $filename;
}


sub _ns_filename {
    my $ns = shift;
    my $filename = 'index.html';
    if ($ns) {
        $filename = 'namespace-' . _pkg_filename($ns);
    }
    return $filename;
}

1;
