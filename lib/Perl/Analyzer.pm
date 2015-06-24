package Perl::Analyzer;
use strict;
use warnings;
use File::Find;
use Storable qw(nstore);
use Perl::Analyzer::File;


=head1 NAME

Perl::Analyzer -  Analyze Perl source

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';


=head1 SYNOPSIS

    my $pa = Perl::Analyzer->new();
    $pa->analyze( '/perl/source/dir' );
    $pa->to_file( 'output.dat' );

=head1 SUBROUTINES/METHODS


=head2 new

=cut

sub new {
    my ($class, %args) = @_;
    my $self = {
        'packages' => {},
        'namespaces' => {},
        'namespace_tree' => {},
        'verbose' => $args{'verbose'},
    };
    bless $self, $class;
    return $self;
}


=head2 debug

=cut

sub debug {
    my ($self, $message) = @_;
    print "$message\n" if $self->{'verbose'};
}


=head2 data

=cut

sub data {
    my $self = shift;
    return {
        packages       => $self->{'packages'},
        namespaces     => $self->{'namespaces'},
        namespace_tree => $self->{'namespace_tree'},
    };
}


=head2 analyze

=cut

sub analyze {
    my ($self, $source_dir) = @_;
    
    $self->build_source_tree($source_dir);
    $self->build_namespace_list();
    $self->build_namespace_tree();
    
    # post-processing
    $self->debug("Post-processing");
    my @packages = keys %{$self->{'packages'}};
    my $numpkg = scalar @packages;
    my $currpkg = 1;
    _progress_set(0);
    
    for my $pkg (@packages) {
        my $pkg_ref = $self->{'packages'}->{$pkg};
        _package_namespaces( $pkg_ref, $self->{'namespaces'} );
        _package_data_sort( $pkg_ref );
        _package_parents( $pkg_ref, $self->{'packages'} );
        _package_methods_hierarchy( $pkg_ref, $self->{'packages'} );
        _package_methods_inherited( $pkg_ref );
        
        if ($self->{'verbose'}) {
            _progress_counter($numpkg, $currpkg);
        }
        $currpkg++;
    }
    $self->debug("Done.");
    
    return $self->data();
}


=head2 to_file

=cut

sub to_file {
    my ($self, $filename) = @_;
    nstore($self->data(), $filename) or die $!;
    return 1;
}


sub build_source_tree {
    my ($self, $source_dir) = @_;
    $self->debug("Building source tree from $source_dir");
    
    my @dir_list = ( $source_dir || '.' );
    my $src_tree = {};
    
    _progress_set(0);
    my $src_files = 0;
    if ($self->{'verbose'}) {
        my $count_files = sub {
            return if -d $_;
            return if ! /\.p[lm]$/;
            $src_files++;
        };
        find($count_files, @dir_list);
    }
    
    my $current_file = 1;
    my $process_file = sub {
        return if -d $_;
        return if ! /\.p[lm]$/;
        my $parsefile = Perl::Analyzer::File->new(
            'file' => $_,
            'rootdir' => $File::Find::dir,
            'with_constants' => 1,
            'with_fields' => 1,
        )->parse();
        foreach my $p (keys %{$parsefile}) {
            $src_tree->{$p} = $parsefile->{$p};
        }
        
        # progress counter
        if ($self->{'verbose'}) {
            _progress_counter($src_files, $current_file);
        }
        $current_file++;
    };
    find($process_file, @dir_list);
    
    $self->{'packages'} = $src_tree;
    return 1;
}


=head2 build_namespace_list

=cut

sub build_namespace_list {
    my ($self) = @_;
    $self->debug("Building namespace list");
    
    my $namespaces = $self->{'namespaces'};
    
    for my $package (keys %{$self->{'packages'}}) {
        for my $ns ( _list_namespaces($package) ) {
            $namespaces->{$ns} = 1;
        }
    }
    # filter out package names from namespace list
    foreach my $ns (keys %{$namespaces}) {
        if ($namespaces->{$ns} == 1 && exists $self->{'packages'}->{$ns}) {
            delete $namespaces->{$ns};
        }
        else {
            $namespaces->{$ns} = [];
        }
    }
    
    for my $package (sort keys %{$self->{'packages'}}) {
        my $namespace;
        if (exists $namespaces->{$package}) {
            # package belongs to the same namespace
            $namespace = $package;
        }
        else {
            if ($package =~ /::/) {
                $package =~ /(.+?)::\w+?$/;
                $namespace = $1;
            }
            else {
                $namespace = '';
            }
        }
        push @{$namespaces->{$namespace}}, $package;
    }
    foreach my $ns (keys %{$namespaces}) {
        $namespaces->{$ns} = [ sort @{$namespaces->{$ns}} ];
    }
}


=head2 build_namespace_tree

=cut

sub build_namespace_tree {
    my ($self) = @_;
    $self->debug("Building namespace tree");
    
    my $namespaces = $self->{'namespaces'};
    
    my $namespace_tree = {};
    for my $package (keys %{$namespaces}) {
        my $t = $namespace_tree;
        my @list_namespaces = (_list_namespaces($package));
        for my $ns ( @list_namespaces ) {
            if (not exists $t->{$ns}) {
                $t->{$ns} = {};
            }
            $t = $t->{$ns};
        }
    }
    
    $self->{'namespace_tree'} = $namespace_tree;
}


=head2 _package_namespaces

=cut

sub _package_namespaces {
    my ($pkg_ref, $namespaces) = @_;
    my @ns_list = _list_namespaces($pkg_ref->{'package'});
    pop @ns_list if not exists $namespaces->{$pkg_ref->{'package'}}; # exclude module itself from namespace list
    $pkg_ref->{'namespaces'} = \@ns_list;
}


=head2 _package_data_sort

=cut

sub _package_data_sort {
    my ($pkg_ref) = @_;
    $pkg_ref->{'methods'}       = [ sort _method_sorter @{$pkg_ref->{'methods'}} ];
    $pkg_ref->{'methods_super'} = [ sort _method_sorter @{$pkg_ref->{'methods_super'}} ];
    $pkg_ref->{'depends_on'}    = [ sort @{$pkg_ref->{'depends_on'}} ];
}


=head2 _package_parents

=cut

sub _package_parents {
    my ($pkg_ref, $src_tree) = @_;
    my @parent_list = _build_inheritance_tree($src_tree, $pkg_ref->{'package'});
    $pkg_ref->{'parent_list'} = \@parent_list;
}


=head2 _package_methods_hierarchy

=cut

sub _package_methods_hierarchy {
    my ($pkg_ref, $src_tree) = @_;
    my $methods_hier = {};
    for my $package (@{$pkg_ref->{'parent_list'}}) {
        next if ! exists $src_tree->{$package}; # skip methods from external packages
        for my $method (@{$src_tree->{$package}->{'methods'}}) {
            if (! exists $methods_hier->{$method}) {
                $methods_hier->{$method} = [];
            }
            if ($package ne $pkg_ref->{'package'}) {
                push @{$methods_hier->{$method}}, $package;
            }
        }
    }
    $pkg_ref->{'methods_hier'} = $methods_hier;
}


=head2 _package_methods_inherited

=cut

sub _package_methods_inherited {
    my ($pkg_ref) = @_;
    my @inherited_methods = ();
    for my $method (sort _method_sorter keys %{$pkg_ref->{'methods_hier'}}) {
        next if scalar grep(/$method/, @{$pkg_ref->{'methods'}});
        push @inherited_methods, $method;
    }
    $pkg_ref->{'methods_inherited'} = \@inherited_methods;
}


=head2 _build_inheritance_tree

=cut

sub _build_inheritance_tree {
    my ($src_tree, $pkg) = @_;
    my @parents = ($pkg);
    if (exists $src_tree->{$pkg}) {
        for my $parent_pkg (@{$src_tree->{$pkg}->{'parent'}}) {
            push @parents, _build_inheritance_tree($src_tree, $parent_pkg);
        }
    }
    return @parents;
}


=head2 _list_namespaces

=cut

sub _list_namespaces {
    my $pkg = shift;
    my @namespace = split(/::/, $pkg);
    my @ns_tree = ();
    for (my $n=1; $n <= scalar @namespace; $n++) {
        my @nsx = @namespace;
        my $ns = join('::', splice(@nsx,0,$n));
        push @ns_tree, $ns;
    }
    return @ns_tree;
}


=head2 _methods_sorter

sort methods: private methods starting from underscores are in the bottom

=cut
sub _method_sorter {
    if (($a =~ /^_/ && $b =~ /^_/)||$a !~ /^_/ && $b !~ /^_/) {
        return $a eq $b ? 0 : $a lt $b ? -1 : 1;
    }
    else {
        return $a =~ /^_/ ? 1 : -1;
    }
}


# progress counter
{
    my $progress = 0;

    sub _progress_set {
        $progress = shift;
    }

    sub _progress_counter {
        my ($total, $current) = @_;
        my $percent = int($current/$total*100);
        if (! ($percent % 10) && $percent != $progress) {
            $progress = $percent;
            print "$percent%\n";
        }
        return '';
    }
}



=head1 AUTHOR

Serhii Mozhaiskyi, C<< <sergei.mozhaisky at gmail.com> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Perl::Analyzer


=head1 ACKNOWLEDGEMENTS

Based on Module::Dependency by Tim Bunce and P Kent.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Serhii Mozhaiskyi

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut


1;