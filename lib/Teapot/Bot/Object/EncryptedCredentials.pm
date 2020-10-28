package Teapot::Bot::Object::EncryptedCredentials;
# ABSTRACT: The base class for Telegram 'EncryptedCredentials' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::EncryptedCredentials::VERSION = '0.021';

has 'data';
has 'hash';
has 'secret';

sub fields {
  return { 'scalar' => [qw/ data hash secret/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::EncryptedCredentials - The base class for Telegram 'EncryptedCredentials' type objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION

See L<https://core.telegram.org/bots/api#encryptedcredentials> for details of the
attributes available for L<Teapot::Bot::Object::EncryptedCredentials> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
