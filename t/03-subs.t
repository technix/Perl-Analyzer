#!/perl
use strict;
use warnings;
use lib qw(./lib ../lib);
use Test::More tests => 12;
use Data::Dumper;

require_ok('Perl::Analyzer::File');

BEGIN {
    if ( -d 't') {
        chdir( 't' );
    }
}

my $file_to_test = 'u/TestSub.pm';
my $key = 'methods';


my $paf = Perl::Analyzer::File->new(file => $file_to_test, rootdir => 'u');

ok( ref $paf eq 'Perl::Analyzer::File', 'create object Perl::Analyzer::File' );

my $data;
eval {
    $data = $paf->parse();
};

ok( ref $data eq 'HASH', 'file parsing successful' );

### 

is_deeply( 
    $data->{'TestSub'}->{$key},
    ['new', 'new1', 'new2'],
    'sub'
);

is(
    $data->{'TestSub::Comments'}->{$key}->[0],
    'new3',
    'commented subs - start'
);

is(
    $data->{'TestSub::Comments'}->{$key}->[1],
    'new4',
    'commented subs - after comment'
);

is(
    $data->{'TestSub::Comments'}->{$key}->[2],
    'new5',
    'commented subs - after pod block'
);

is(
    $data->{'TestSub::Comments'}->{$key}->[3],
    'new6',
    'commented subs - after pod block 2'
);




is_deeply(
    $data->{'TestSub::Nested'}->{$key},
    ['new0', 'new1'],
    'nested subs'
);

TODO: {
    local $TODO = 'Parse named subs';

is_deeply(
    $data->{'TestSub::Named'}->{$key},
    ['new0','new1'],
    'named subs'
);

}

# SUPER methods

is_deeply(
    $data->{'TestSub::Super'}->{'methods_super'},
    ['test'],
    'SUPER methods'
);


# Call methods from other modules

is_deeply(
    $data->{'TestSub::Call'}->{'methods_used'},
    { 'Carp' => ['croak', 'longmess'], 'File::Spec' => ['catdir', 'catfile'] },
    'Call methods from other modules'
) or diag (Dumper($data->{'TestSub::Call'}->{'methods_used'}));


### 

done_testing();

1;