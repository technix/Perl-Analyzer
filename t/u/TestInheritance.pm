package TestInheritance;
use lib '.';

package TestP;
 # test comments etc. for false positives

#use base 'anything';
#use parent 'something';
=for
use base 'anything';
use parent 'something';
=cut
my $a = "use base 'TestM::Pkg1'";
my $b = "use parent 'TestM::Pkg2'";
my $c = qq/ use base 'TestM' /;
my $d = qq/ use parent 'TestM' /;
my $e = "\@ISA = ('TestM')";
my $f = qq/ @ISA = ('TestM'); /;



# -- use base


package TestP::Base;
use lib '.';
use base 'TestM';


package TestP::BaseQw;
use lib '.';
use base qw( TestM::Pkg1 );


package TestP::BaseMultiple;
use lib '.';
use base qw( TestM::Pkg1 TestM::Pkg2 );

package TestP::BaseMultiline;
use lib '.';
use base qw( TestM::Pkg1
    TestM::Pkg2
 TestM::Pkg3 );


# -- use parent

# 'use parent' requires physical files
package TestP::Parent;
use lib '.';
use parent 'TestM';


package TestP::ParentQw;
use lib '.';
use parent qw( TestM::Pkg1 );


package TestP::ParentMultiple;
use lib '.';
use parent qw( TestM::Pkg1 TestM::Pkg2 );

package TestP::ParentMultiline;
use lib '.';
use parent qw( TestM::Pkg1
 TestM::Pkg2
    TestM::Pkg3 );



# -- @ISA

package TestP::Isa;
our @ISA = ('TestP');


package TestP::IsaPkg;
@TestP::IsaPkg::ISA = ('TestP::Base');


package TestP::IsaPush;
our @ISA;
push @ISA, 'TestP';
push @ISA, 'TestP::Base';


package TestP::IsaPkgPush;
push @TestP::IsaPkgPush::ISA, 'TestP';
push @TestP::IsaPkgPush::ISA, 'TestP::Base';


1;
