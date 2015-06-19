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


1;
