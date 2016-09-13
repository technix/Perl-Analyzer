Perl-Analyzer
========================

http://technix.github.io/Perl-Analyzer/

This is a set of programs (and modules which can be used separately)
that allow you to analyse and visualise Perl codebases:

* Namespaces and their relations
* Dependencies, i.e. list of 'use'd or 'require'd packages
* Inheritance, i.e. list of parent packages
* Methods implemented in package
* Methods inherited from parent packages
* Methods redefined from parent packages
* Calls to methods from parent package via SUPER

The software is split into two parts - analyzer (perl-analyzer, which uses
Perl::Analyzer module) and renderer (perl-analyzer-output, which uses
Perl::Analyzer::Output and related plugins).

Usage example:

    perl-analyzer --source-dir=~/my/perl/Project --datafile=~/my/perl/Project_src.dat
    perl-analyzer-output --datafile=~/my/perl/Project_src.dat --output-dir=~/my/perl/Project_analysis --format=html

Available output formats:

**dump** (requires Data::Dumper)

Generates set of dump files for Perl::Analyzer structures. Useful for debugging purposes.

**json** (requires JSON)

Generates set of JSON files.

**html** (requires Text::MicroTemplate and JSON)

Generates set of HTML files. Most informative and useful output - it allows to navigate
through namespaces and view detailed package information.

**dot, svg, png** (requires GraphViz2)

Generates namespace and inheritance diagrams in given format.


INSTALLATION
------------------------

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install


ACKNOWLEDGEMENTS
------------------------

File analyzer code based on Module::Dependency by Tim Bunce and P Kent.


LICENSE AND COPYRIGHT
------------------------

Copyright (C) 2015 Serhii Mozhaiskyi

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0).
