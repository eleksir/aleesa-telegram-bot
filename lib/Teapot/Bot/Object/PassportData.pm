package Teapot::Bot::Object::PassportData;
# ABSTRACT: The base class for Telegram 'PassportData' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::EncryptedPassportElement;
use Teapot::Bot::Object::EncryptedCredentials;

$Teapot::Bot::Object::PassportData::VERSION = '0.022';

has 'data'; # Array of EncryptedPassportElement
has 'credentials'; # EncryptedCredentials

sub fields {
  return {
            'Teapot::Bot::Object::EncryptedPassportElement' => [qw/data/],
            'Teapot::Bot::Object::EncryptedCredentials'     => [qw/credentials/],
         };
}

sub arrays {
  return qw/data/;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::PassportData - The base class for Telegram 'PassportData' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'PassportData' type objects.

See L<https://core.telegram.org/bots/api#passportdata> for details of the
attributes available for L<Teapot::Bot::Object::PassportData> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
