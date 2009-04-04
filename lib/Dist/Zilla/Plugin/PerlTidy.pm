package Dist::Zilla::Plugin::PerlTidy;

# ABSTRACT: PerlTidy in Dist::Zilla

use Moose;
with 'Dist::Zilla::Role::FileMunger';

has 'perltidyrc';

sub munge_file {
    my ( $self, $file ) = @_;

    return $self->munge_perl($file) if $file->name    =~ /\.(?:pm|pl|t)$/i;
    return $self->munge_perl($file) if $file->content =~ /^#!perl(?:$|\s)/;
    return;
}

sub munge_perl {
    my ( $self, $file ) = @_;

    my $content = $file->content;

    my $perltidyrc = ( $self->perltidyrc and exists $self->perltidyrc ) ?
        $self->perltidyrc : undef;

    # make Perl::Tidy happy
    local @ARGV = ();

    my $tided;
    require Perl::Tidy;
    Perl::Tidy::perltidy(
        source      => \$content,
        destination => \$tided,
        perltidyrc  => $perltidyrc,
    );

    $file->content($tided);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
__END__

=head1 NAME

Dist::Zilla::Plugin::PerlTidy - PerlTidy in Dist::Zilla

=head1 SYNOPSIS

    # dist.ini
    [PerlTidy]

=head1 TODO

Make perltidyrc configurable

=head1 AUTHOR

Fayland Lam, C<< E<lt>fayland@gmail.comE<gt> >>

=head1 COPYRIGHT

Copyright 2008, Fayland Lam.

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
