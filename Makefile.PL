use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Perl::Analyzer',
    AUTHOR           => q{Serhii Mozhaiskyi <sergei.mozhaisky@gmail.com>},
    VERSION_FROM     => 'lib/Perl/Analyzer.pm',
    ABSTRACT_FROM    => 'lib/Perl/Analyzer.pm',
    LICENSE          => 'bsd',
    PL_FILES         => {},
    EXE_FILES        => [
        'bin/perl-analyzer',
        'bin/perl-analyzer-output'
    ],
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Cwd'           => 0,
        'FindBin'       => 0,
        'Storable'      => 0,
        'Getopt::Long'  => 0,
        'Pod::Usage'    => 0,
        'File::Basename'    => 0,
        'File::Copy'    => 0,
        'File::Find'    => 0,
        'File::Path'    => 0,
        'File::Spec'    => 0,
        'Data::Dumper'  => 0,
        'JSON'          => 0,
        'Text::MicroTemplate' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Perl-Analyzer-*' },
);
