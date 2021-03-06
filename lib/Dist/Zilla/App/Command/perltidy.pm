package Dist::Zilla::App::Command::perltidy;

use strict;
use warnings;

# ABSTRACT: perltidy your dist
use Dist::Zilla::App -command;

sub abstract { 'perltidy your dist' }

sub execute {
    my ( $self, $opt, $arg ) = @_;

    my $perltidyrc;
    if ( scalar @$arg and -e $arg->[0] ) {
        $perltidyrc = $arg->[0];
    }
    else {
        my $config = $self->app->config_for('Dist::Zilla::Plugin::PerlTidy');
        if ( exists $config->{perltidyrc} ) {
            if ( -e $config->{perltidyrc} ) {
                $perltidyrc = $config->{perltidyrc};
            }
            else {
                warn "perltidyrc $config->{perltidyrc} is not found\n";
            }
        }
        $perltidyrc ||= $ENV{PERLTIDYRC};
    }

    # make Perl::Tidy happy
    local @ARGV = ();

    require Perl::Tidy;
    require File::Copy;
    require File::Next;

    my $files = File::Next::files('.');
    while ( defined( my $file = $files->() ) ) {
        next unless ( $file =~ /\.(t|p[ml])$/ );    # perl file
        my $tidyfile = $file . '.tdy';
        Perl::Tidy::perltidy(
            source      => $file,
            destination => $tidyfile,
            perltidyrc  => $perltidyrc,
        );
        File::Copy::move( $tidyfile, $file );
    }

    return 1;
}

1;

=head1 SYNOPSIS

    $ dzil perltidy
    # OR
    $ dzil perltidy .myperltidyrc

=head2 perltidyrc

=head3 dzil config

In your global dzil setting (which is '~/.dzil' or '~/.dzil/config.ini'), you can config the
 perltidyrc like:

    [PerlTidy]
    perltidyrc = /home/fayland/somewhere/.perltidyrc

=head3 ENV PERLTIDYRC

If you do not config the dzil, we will fall back to ENV PERLTIDYRC

    export PERLTIDYRC=/home/fayland/somwhere2/.perltidyrc
