package TestSub;
use lib '.';

sub new {};

sub new1 {
    1;
}

sub new2
{
    1;
}

1;

#-------------------------------

package TestSub::Comments;

sub new3 {
  3;
}

# sub new0 {}

# sub new1 {
#    return 1;
# }

# sub after comments

sub new4 {
  4;
}

=for
sub new2 
{
    return 1;
}
=cut

# sub after pod block
sub new5 {
  5;
}

=head
sub new7
{
    return 1;
}
=cut

# sub after pod block
sub new6 {
  6;
}


1;

#-------------------------------

package TestSub::Nested;

sub new0 {
    my $a = 1;
    sub new1 {
        my $b = 2;
    }
    new1();
}

1;

#-------------------------------

package TestSub::Named;

my $new0 = sub {
    1;
};

my $new1 = sub {
    2;
};

#-------------------------------
package TestSub::Super;
use base 'TestM';

sub test {
  my $a = SUPER::test();
}

#-------------------------------
package TestSub::Call;
use Carp;
use File::Spec;

sub test {
  my $a = Carp::croak();
  my $b = Carp::longmess('test');
  ##my $c = Carp::cluck; # no parentheses
  # complex names
  ## my $d = File::Spec::rootdir; # no parentheses
  my $e = File::Spec::catdir('a','b');
}

sub testb {
  my $c = File::Spec->catfile('/tmp/zzz'); # class method
}



1;
