package Mojolicious::Plugin::ReverseProxyWithPath;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::File qw(curfile path);

our $VERSION = '0.01';

use constant DEBUG => $ENV{MOJO_REVERSEPROXY_DEBUG} || 0;

sub register {
  my ($self, $app) = @_;
  $app->helper(base => sub {
    my $c = shift;
    $c->tag('base', href => $c->req->url->base, @_);
  });
  $app->hook(before_dispatch => sub {
    my $c = shift;
    if ( $ENV{MOJO_REVERSE_PROXY} && $ENV{MOJO_REVERSE_PROXY} =~ /^\D/ ) {
      my $rp = Mojo::URL->new($ENV{MOJO_REVERSE_PROXY});
      my $url = $c->req->url;
      my $base = $url->base;
      $base->scheme($rp->scheme)->host($rp->host)->port($rp->port)
        if $rp->scheme && $rp->host_port;
      push @{$base->path}, grep /\S/, @{$rp->path};
      $base->path->trailing_slash(1);
      $url->path->leading_slash(0);
      $c->req->headers->header('X-Request-Base' => $base->to_abs->to_string);
      warn "[MOJO_REVERSE_PROXY=$ENV{MOJO_REVERSE_PROXY}] Base: ".$c->req->url->base if DEBUG;
      warn "[MOJO_REVERSE_PROXY=$ENV{MOJO_REVERSE_PROXY}]  URL: ".$c->req->url if DEBUG;
    }
    if ( my $base = $c->req->headers->header('X-Request-Base') ) {
      my $url = Mojo::URL->new($base);
      if ( $url->host ) {
        $c->req->url->base($url);
      }
      else {
        $c->req->url->base->path($url->path);
      }
      warn "[X-Request-Base] Base: ".$c->req->url->base if DEBUG;
      warn "[X-Request-Base]  URL: ".$c->req->url if DEBUG;
    }
  });
}

1;

__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::ReverseProxyWithPath - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('ReverseProxyWithPath');

  # Mojolicious::Lite
  plugin 'ReverseProxyWithPath';

  #location ~ ^/(?<app>[a-zA-z]+)(?<ruri>.*)$ {
  #  if ( $ruri = "" ) {
  #    set $ruri "/";
  #  }
  #  proxy_pass http://unix:/var/mojo/unixsockets/$app.$http_host:$ruri$is_args$args;
=head1 DESCRIPTION

L<Mojolicious::Plugin::ReverseProxyWithPath> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::ReverseProxyWithPath> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.
# https://mojolicious.io/blog/2019/03/18/reverse-proxy-with-path/

=cut
