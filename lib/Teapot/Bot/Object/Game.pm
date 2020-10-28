package Teapot::Bot::Object::Game;
$Teapot::Bot::Object::Game::VERSION = '0.021';
# ABSTRACT: The base class for Telegram message 'Game' type.


use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PhotoSize;
use Teapot::Bot::Object::Animation;
use Teapot::Bot::Object::MessageEntity;

has 'title';
has 'description';
has 'photo'; # Array of PhotoSize
has 'text';
has 'text_entities'; #Array of MessageEntity
has 'animation'; #Animation

sub fields {
  return { scalar                                 => [qw/title description text/],
           'Teapot::Bot::Object::PhotoSize'     => [qw/photo/],
           'Teapot::Bot::Object::MessageEntity' => [qw/text_entities/],
           'Teapot::Bot::Object::Animation'     => [qw/animation/],
         };
}

sub arrays { qw/photo text_entities/ }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Game - The base class for Telegram message 'Game' type.

=head1 VERSION

version 0.021

=head1 DESCRIPTION

See L<https://core.telegram.org/bots/api#game> for details of the
attributes available for L<Teapot::Bot::Object::Game> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
