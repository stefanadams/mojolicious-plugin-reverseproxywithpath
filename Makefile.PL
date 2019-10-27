use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::ReverseProxyWithPath',
  VERSION_FROM => 'lib/Mojolicious/Plugin/ReverseProxyWithPath.pm',
  PREREQ_PM    => {'Mojolicious' => '8.24'},
  ABSTRACT     => 'Reply with a simple response of just the current time',
  AUTHOR       => 'Stefan Adams <sadams@cpan.org>',
  LICENSE      => '',
  META_MERGE   => {
    dynamic_config => 0,
    'meta-spec'    => {version => 2},
    no_index       => {
      directory => [qw(t)],
    },
    prereqs   => {runtime => {requires => {perl => '5.010001'}}},
    resources => {
      bugtracker => {web => 'https://github.com/stefanadams/mojolicious-plugin-reverseproxywithpath/issues'},
      homepage   => 'https://stefan.adams.fm',
      license    => ['http://www.opensource.org/licenses/artistic-license-2.0'],
      repository => {
        type => 'git',
        url  => 'https://github.com/stefanadams/mojolicious-plugin-reverseproxywithpath.git',
        web  => 'https://github.com/stefanadams/mojolicious-plugin-reverseproxywithpath',
      },
      x_IRC => 'irc://irc.freenode.net/#mojo'
    },
  },
  test         => {TESTS => 't/*.t'}
);

