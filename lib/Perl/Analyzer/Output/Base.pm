package Perl::Analyzer::Output::Base;
use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
use File::Spec;
use File::Path qw(make_path);


sub create_output_dir {
    my $self = shift;
    if (! $self->{'output_dir'}) {
        $self->{'output_dir'} = File::Spec->catdir(cwd(), 'result');
    }
    make_path( $self->{'output_dir'} );
    # store real path
    $self->{'output_dir'} = abs_path($self->{'output_dir'});
}


sub output_file {
    my ($self, $filename) = @_;
    return File::Spec->catfile($self->{'output_dir'}, $filename);
}


sub save_file {
    my ($self, $filename, $content) = @_;
    open my $fh, '>', $filename;
    print ${fh} $content;
    close $fh;
    return 1;
}


sub debug {
    my ($self, $message) = @_;
    print "$message\n" if $self->{'verbose'};
}

# progress counter
{
    my $progress = 0;

    sub progress_set {
        my $self = shift;
        $progress = shift;
    }

    sub progress_counter {
        my $self = shift;
        my ($total, $current) = @_;
        my $percent = int($current/$total*100);
        if (! ($percent % 10) && $percent != $progress) {
            $progress = $percent;
            print "$percent%\n";
        }
        return '';
    }
}

1;
