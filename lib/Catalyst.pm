package Catalyst;

use strict;
use base 'Class::Data::Inheritable';
use UNIVERSAL::require;
use Catalyst::Log;

__PACKAGE__->mk_classdata($_) for qw/_config log/;

our $VERSION = '4.32';
our @ISA;

=head1 NAME

Catalyst - The Elegant MVC Web Application Framework

=head1 SYNOPSIS

    # use the helper to start a new application
    catalyst.pl MyApp
    cd MyApp

    # add models, views, controllers
    script/create.pl model Something
    script/create.pl view Stuff
    script/create.pl controller Yada

    # built in testserver
    script/server.pl

    # command line interface
    script/test.pl /yada


    use Catalyst;

    use Catalyst qw/My::Module My::OtherModule/;

    use Catalyst '-Debug';

    use Catalyst qw/-Debug -Engine=CGI/;

    __PACKAGE__->action( '!default' => sub { $_[1]->res->output('Hello') } );

    __PACKAGE__->action(
        'index.html' => sub {
            my ( $self, $c ) = @_;
            $c->res->output('Hello');
            $c->forward('_foo');
        }
    );

    __PACKAGE__->action(
        '/^product[_]*(\d*).html$/' => sub {
            my ( $self, $c ) = @_;
            $c->stash->{template} = 'product.tt';
            $c->stash->{product} = $c->req->snippets->[0];
        }
    );

See also L<Catalyst::Manual::Intro>

=head1 DESCRIPTION

Catalyst is based upon L<Maypole>, which you should consider for smaller
projects.

The key concept of Catalyst is DRY (Don't Repeat Yourself).

See L<Catalyst::Manual> for more documentation.

Catalyst plugins can be loaded by naming them as arguments to the "use Catalyst" statement.
Omit the C<Catalyst::Plugin::> prefix from the plugin name, 
so C<Catalyst::Plugin::My::Module> becomes C<My::Module>.

    use Catalyst 'My::Module';

Special flags like -Debug and -Engine can also be specifed as arguments when
Catalyst is loaded:

    use Catalyst qw/-Debug My::Module/;

The position of plugins and flags in the chain is important, because they are
loaded in exactly the order that they appear.

The following flags are supported:

=over 4

=item -Debug

enables debug output, i.e.:

    use Catalyst '-Debug';

this is equivalent to:

    use Catalyst;
    sub debug { 1 }

=item -Engine

Force Catalyst to use a specific engine.
Omit the C<Catalyst::Engine::> prefix of the engine name, i.e.:

    use Catalyst '-Engine=CGI';

=back

=head1 METHODS

=over 4

=item debug

Overload to enable debug messages.

=cut

sub debug { 0 }

=item config

Returns a hashref containing your applications settings.

=cut

sub config {
    my $self = shift;
    $self->_config( {} ) unless $self->_config;
    if ( $_[0] ) {
        my $config = $_[1] ? {@_} : $_[0];
        while ( my ( $key, $val ) = each %$config ) {
            $self->_config->{$key} = $val;
        }
    }
    return $self->_config;
}

sub import {
    my ( $self, @options ) = @_;
    my $caller = caller(0);

    # Class
    {
        no strict 'refs';
        *{"$caller\::handler"} =
          sub { Catalyst::Engine::handler( $caller, @_ ) };

        unless ( $caller->isa($self) ) {
            push @{"$caller\::ISA"}, $self;
        }
    }

    unless ( $caller->log ) {
        $caller->log( Catalyst::Log->new );
    }

    # Options
    my $engine =
      $ENV{MOD_PERL} ? 'Catalyst::Engine::Apache' : 'Catalyst::Engine::CGI';
    foreach (@options) {
        if (/^\-Debug$/) {
            no warnings;
            no strict 'refs';
            *{"$caller\::debug"} = sub { 1 };
            $caller->log->debug('Debug messages enabled');
        }
        elsif (/^-Engine=(.*)$/) { $engine = "Catalyst::Engine::$1" }
        elsif (/^-.*$/) { $caller->log->error(qq/Unknown flag "$_"/) }
        else {
            my $plugin = "Catalyst::Plugin::$_";

            # Plugin caller should be our application class
            eval "package $caller; require $plugin";
            if ($@) {
                $caller->log->error(qq/Couldn't load plugin "$plugin", "$@"/);
            }
            else {
                $caller->log->debug(qq/Loaded plugin "$plugin"/)
                  if $caller->debug;
                no strict 'refs';
                push @{"$caller\::ISA"}, $plugin;
            }
        }
    }

    # Engine
    $engine = "Catalyst::Engine::$ENV{CATALYST_ENGINE}"
      if $ENV{CATALYST_ENGINE};
    $engine->require;
    die qq/Couldn't load engine "$engine", "$@"/ if $@;
    {
        no strict 'refs';
        push @{"$caller\::ISA"}, $engine;
    }
    $caller->log->debug(qq/Loaded engine "$engine"/) if $caller->debug;
}

=item $c->log

Contains the logging object.  Unless it is already set Catalyst sets this up with a
C<Catalyst::Log> object.  To use your own log class:

    $c->log( MyLogger->new );
    $c->log->info("now logging with my own logger!");

Your log class should implement the methods described in the C<Catalyst::Log>
man page.


=back

=head1 SUPPORT

IRC:

    Join #catalyst on irc.perl.org.

Mailing-Lists:

    http://lists.rawmode.org/mailman/listinfo/catalyst
    http://lists.rawmode.org/mailman/listinfo/catalyst-dev
    
=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Engine>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 THANK YOU

Andrew Ford, Andrew Ruthven, Christian Hansen, Christopher Hicks,
Danijel Milicevic, David Naughton, Gary Ashton Jones, Jesse Sheidlower,
Johan Lindstrom, Marcus Ramberg, Tatsuhiko Miyagawa and all the others
who've helped.

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
