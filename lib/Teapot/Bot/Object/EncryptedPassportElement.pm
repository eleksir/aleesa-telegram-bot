package Teapot::Bot::Object::EncryptedPassportElement;
# ABSTRACT: The base class for Telegram 'EncryptedPassportElement' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::EncryptedPassportElement::VERSION = '0.022';

# XXX Implement rest of this
# https://core.telegram.org/bots/api#encryptedpassportelement

has 'type';
has 'data';
has 'phone_number';
has 'email';

# XXX more here

sub fields {
  return { 'scalar' => [qw/type data phone_number email/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::EncryptedPassportElement - The base class for Telegram 'EncryptedPassportElement' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'EncryptedPassportElement' type objects.

See L<https://core.telegram.org/bots/api#encryptedpassportelement> for details of the
attributes available for L<Teapot::Bot::Object::EncryptedPassportElement> objects.

Note that this type is not yet fully implemented.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
