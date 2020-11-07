package Teapot::Bot::Object::CallbackGame;
# ABSTRACT: The base class for Telegram message 'CallbackGame' type.

use Mojo::Base 'Teapot::Bot::Object::Base';
$Teapot::Bot::Object::CallbackGame::VERSION = '0.022';

# https://core.telegram.org/bots/api#callbackgame
# "A placeholder, currently holds no information. Use BotFather to set up your game"

sub fields {
  return { },
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::CallbackGame - The base class for Telegram message 'CallbackGame' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'CallbackGame' type.

See L<https://core.telegram.org/bots/api#callbackgame> for details of the
attributes available for L<Teapot::Bot::Object::CallbackGame> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
