package Mojolicious::Plugin::ReverseProxyWithPath;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::File 'curfile';

our $VERSION = '0.01';

sub register {
  my ($self, $app) = @_;
  # https://mojolicious.io/blog/2019/03/18/reverse-proxy-with-path/
  #location ~ ^/(?<app>[a-zA-z]+)(?<ruri>.*)$ {
  #  if ( $ruri = "" ) {
  #    set $ruri "/";
  #  }
  #  proxy_pass http://unix:/var/mojo/unixsockets/$app.$http_host:$ruri$is_args$args;
  if ( my $path = $ENV{MOJO_REVERSE_PROXY} ) {
    my @path_parts = grep /\S/, split m/\//, $path;
    $app->hook(before_dispatch => sub {
      my $c = shift;
      my $url = $c->req->url;
      my $base = $url->base;
      push @{$base->path}, @path_parts;
      $base->path->trailing_slash(1);
      $url->path->leading_slash(0);
    }) if $path =~ /^\//;
    $app->hook(after_render => sub {
      my ($c, $output, $format) = @_;
      my $dom = Mojo::DOM->new($$output);
      # TODO: return if there's already a shortcut icon in the DOM
      my $icon = $c->app->mode eq 'production' ? '/favicon.ico' : '/favicon.'.$c->app->mode.'.ico';
      $icon = $dom->new_tag('link', rel=>"shortcut icon", href=>$c->url_for($icon), type=>"image/x-icon");
      if ( $dom->at('html > head') ) {
        $$output = $dom->at('html > head')->child_nodes->first->prepend($icon)->root
      } elsif ( $dom->at('html') ) {
        $$output = $dom->at('html')->child_nodes->first->prepend($icon)->root
      } else {
        $$output = "$icon\n$$output";
      }
    });
    # Static files
    my $resources = curfile->sibling('ReverseProxyWithPath', 'resources');
    push @{$app->static->paths}, $resources->child('public')->to_string;
  }
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

=cut
