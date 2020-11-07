package Teapot::Bot::Object::InlineKeyboardMarkup;
# ABSTRACT: The base class for Telegram 'InlineKeyboardMarkup' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::InlineKeyboardButton;

$Teapot::Bot::Object::InlineKeyboardMarkup::VERSION = '0.022';

has 'inline_keyboard';

sub fields {
  return { 'Teapot::Bot::Object::InlineKeyboardButton' => [qw/inline_keyboard/] };
}

sub array_of_arrays {
  return qw/inline_keyboard/;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::InlineKeyboardMarkup - The base class for Telegram 'InlineKeyboardMarkup' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'InlineKeyboardMarkup' type objects.

See L<https://core.telegram.org/bots/api#inlinekeyboardmarkup> for details of the
attributes available for L<Teapot::Bot::Object::InlineKeyboardMarkup> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
