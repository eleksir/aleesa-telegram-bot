package Teapot::Bot::Object::PhotoSize;
# ABSTRACT: The base class for Telegram message 'PhotoSize' type.

use Mojo::Base 'Teapot::Bot::Object::Base';
use Carp qw/croak/;

$Teapot::Bot::Object::PhotoSize::VERSION = '0.022';

has 'file_id';
has 'file_unique_id';
has 'width';
has 'height';
has 'file_size';

sub fields {
  return { scalar => [qw/file_id file_unique_id width height file_size/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::PhotoSize - The base class for Telegram message 'PhotoSize' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'PhotoSize' type.

See L<https://core.telegram.org/bots/api#photosize> for details of the
attributes available for L<Teapot::Bot::Object::PhotoSize> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
