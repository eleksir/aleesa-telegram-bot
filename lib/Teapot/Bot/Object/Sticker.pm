package Teapot::Bot::Object::Sticker;
# ABSTRACT: The base class for Telegram message 'Sticker' type.

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PhotoSize;

$Teapot::Bot::Object::Sticker::VERSION = '0.022';

has 'file_id';
has 'width';
has 'height';
has 'thumb'; # PhotoSize
has 'emoji';
has 'set_name';
# has 'mask_position'; # XXX TODO
has 'file_size';

sub fields {
  return {
           scalar                           => [ qw/file_id width height emoji set_name file_size/ ],
           'Teapot::Bot::Object::PhotoSize' => [ qw/thumb/ ],
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Sticker - The base class for Telegram message 'Sticker' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'Sticker' type.

See L<https://core.telegram.org/bots/api#sticker> for details of the
attributes available for L<Teapot::Bot::Object::Sticker> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
