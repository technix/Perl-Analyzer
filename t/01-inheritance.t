#!/perl
use strict;
use warnings;
use lib qw(./lib ../lib);
use Test::More tests => 16;

require_ok('Perl::Analyzer::File');

BEGIN {
    if ( -d 't') {
        chdir( 't' );
    }
}

my $file_to_test = 'u/TestInheritance.pm';
my $parent_key = 'parent';


my $paf = Perl::Analyzer::File->new(file => $file_to_test, rootdir => 'u');

ok( ref $paf eq 'Perl::Analyzer::File', 'create object Perl::Analyzer::File' );

my $data;
eval {
    $data = $paf->parse();
};

ok( ref $data eq 'HASH', 'file parsing successful' );

### use base

is_deeply( 
    $data->{'TestP'}->{$parent_key},
    [],
    'no parents'
);

is_deeply(
    $data->{'TestP::Base'}->{$parent_key},
    ['TestM'],
    'use base \'a\''
);

is_deeply(
    $data->{'TestP::BaseQw'}->{$parent_key},
    ['TestM::Pkg1'],
    'use base qw(a)'
);

is_deeply(
    $data->{'TestP::BaseMultiple'}->{$parent_key},
    ['TestM::Pkg1', 'TestM::Pkg2'],
    'use base qw(a b)'
);


is_deeply(
    $data->{'TestP::BaseMultiline'}->{$parent_key},
    ['TestM::Pkg1', 'TestM::Pkg2', 'TestM::Pkg3'],
    'use base qw(a b) - multiline'
);


### use parent

is_deeply(
    $data->{'TestP::Parent'}->{$parent_key},
    ['TestM'],
    'use parent \'a\''
);

is_deeply(
    $data->{'TestP::ParentQw'}->{$parent_key},
    ['TestM::Pkg1'],
    'use parent qw(a)'
);

is_deeply(
    $data->{'TestP::ParentMultiple'}->{$parent_key},
    ['TestM::Pkg1', 'TestM::Pkg2'],
    'use parent qw(a b)'
);

is_deeply(
    $data->{'TestP::ParentMultiline'}->{$parent_key},
    ['TestM::Pkg1', 'TestM::Pkg2', 'TestM::Pkg3'],
    'use parent qw(a b) - multiline'
);


### @ISA

is_deeply(
    $data->{'TestP::Isa'}->{$parent_key},
    ['TestP'],
    '@ISA'
);

TODO: {
    local $TODO = 'Package-scoped @ISA';

is_deeply(
    $data->{'TestP::IsaPkg'}->{$parent_key},
    ['TestP::Base'],
    '@Package::ISA'
);

}

TODO: {
    local $TODO = 'Push to @ISA';


is_deeply(
    $data->{'TestP::IsaPush'}->{$parent_key},
    ['TestP', 'TestP::Base'],
    'push @ISA'
);

is_deeply(
    $data->{'TestP::IsaPkgPush'}->{$parent_key},
    ['TestP', 'TestP::Base'],
    'push @Package::ISA'
);

}

### 

done_testing();

1;