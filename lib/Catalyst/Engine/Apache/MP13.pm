package Catalyst::Engine::Apache::MP13;

use strict;
use base qw[Catalyst::Engine::Apache::MP13::Base Catalyst::Engine::CGI];

=head1 NAME

Catalyst::Engine::Apache::MP13 - Catalyst Apache MP13 Engine

=head1 SYNOPSIS

See L<Catalyst>.

=head1 DESCRIPTION

This is the Catalyst engine specialized for Apache mod_perl version 1.3x.

=head1 OVERLOADED METHODS

This class overloads some methods from C<Catalyst::Engine::Apache::MP13::Base>
and C<Catalyst::Engine::CGI>.

=over 4

=item $c->prepare_body

=cut

sub prepare_body { 
    shift->Catalyst::Engine::CGI::prepare_body(@_);
}

=item $c->prepare_parameters

=cut

sub prepare_parameters { 
    shift->Catalyst::Engine::CGI::prepare_parameters(@_);
}

=item $c->prepare_request

=cut

sub prepare_request {
    my ( $c, $r, @arguments ) = @_;
    
    $ENV{CONTENT_TYPE}   = $r->header_in("Content-Type");
    $ENV{CONTENT_LENGTH} = $r->header_in("Content-Length");
    $ENV{QUERY_STRING}   = $r->args;
    $ENV{REQUEST_METHOD} = $r->method;

    $c->SUPER::prepare_request($r);
    $c->Catalyst::Engine::CGI::prepare_request( $r, @arguments );
}

=item $c->prepare_uploads

=cut

sub prepare_uploads { 
    shift->Catalyst::Engine::CGI::prepare_uploads(@_);
}

=back

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Engine>, L<Catalyst::Engine::Apache::Base>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
