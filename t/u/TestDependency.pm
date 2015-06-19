package TestDependency;
use lib '.';
# simple use
use TestM; 
use TestM::Pkg1; 

sub new {};
1;

#------------------------------------

package TestD::Require;
# require
require TestM::Pkg1;
 
sub new {};
1;

#------------------------------------

package TestD::RequireFile;
# require
require 'TestM/Pkg2.pm';
 
sub new {};
1;


#------------------------------------

package TestD::RequireConditional;
require TestM if $a;

sub new {};
1;

#------------------------------------

package TestD::UseImports;
use TestM::Pkg1 qw( new1 new2 );
use TestM::Pkg2 qw( new3 new4 new5 );

sub new {};
1;

#------------------------------------
package TestD::UseInSub;
use TestM::Pkg1;

sub new {
    if (1) {
        use TestM::Pkg2;
    }
    else {
        use TestM::Pkg3;
    }
};

1;


#------------------------------------
 
package TestD::Comments;
# test comments etc. for false positives
#use TestM;
#use TestM::Pkg1;
=for
use TestM;
use TestM::Pkg1;
=cut
my $a = "use TestM::Pkg1;";
my $c = qq/ use TestM::Pkg1 /;

#------------------------------------

package TestD::Pragmas;
use strict;
use warnings;
use utf8;
use base 'TestM::Pkg1';
use parent qw( TestM::Pkg2 );

sub new {};
1;


1;
