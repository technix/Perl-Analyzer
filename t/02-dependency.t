#!/perl
use strict;
use warnings;
use lib qw(./lib ../lib);
use Test::More tests => 11;

require_ok('Perl::Analyzer::File');

BEGIN {
    if ( -d 't') {
        chdir( 't' );
    }
}

my $file_to_test = 'u/TestDependency.pm';
my $key = 'depends_on';


my $paf = Perl::Analyzer::File->new(file => $file_to_test, rootdir => 'u');

ok( ref $paf eq 'Perl::Analyzer::File', 'create object Perl::Analyzer::File' );

my $data;
eval {
    $data = $paf->parse();
};

ok( ref $data eq 'HASH', 'file parsing successful' );

### use base

is_deeply( 
    $data->{'TestDependency'}->{$key},
    ['lib','TestM','TestM::Pkg1'],
    'use'
);

is_deeply(
    $data->{'TestD::Require'}->{$key},
    ['TestM::Pkg1'],
    'require'
);


TODO: {
    local $TODO = 'require filename';

is_deeply(
    $data->{'TestD::RequireFile'}->{$key},
    ['TestM::Pkg2'],
    'require'
);

}

is_deeply(
    $data->{'TestD::RequireConditional'}->{$key},
    ['TestM'],
    'require if'
);

is_deeply(
    $data->{'TestD::UseImports'}->{$key},
    ['TestM::Pkg1', 'TestM::Pkg2'],
    'use with import'
);


is_deeply(
    $data->{'TestD::UseInSub'}->{$key},
    ['TestM::Pkg1', 'TestM::Pkg2', 'TestM::Pkg3'],
    'use in subroutines'
);


is_deeply(
    $data->{'TestD::Comments'}->{$key},
    [],
    'comments'
);

is_deeply(
    $data->{'TestD::Pragmas'}->{$key},
    ['strict', 'warnings', 'utf8', 'base', 'parent'],
    'use in subroutines'
);


### 

done_testing();

1;