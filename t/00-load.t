#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Perl::Analyzer' ) || print "Bail out!\n";
    use_ok( 'Perl::Analyzer::Output' ) || print "Bail out!\n";
}

diag( "Testing Perl::Analyzer $Perl::Analyzer::VERSION, Perl $], $^X" );
