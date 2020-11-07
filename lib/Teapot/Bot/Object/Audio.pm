package Teapot::Bot::Object::Audio;
# ABSTRACT: The base class for Telegram 'Audio' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Audio::VERSION = '0.022';

has 'file_id';
has 'duration';
has 'performer';
has 'title';
has 'mime_type';
has 'file_size';
has 'thumb'; #PhotoSize

sub fields {
  return { scalar                           => [qw/file_id duration performer title mime_type file_size/],
           'Teapot::Bot::Object::PhotoSize' => [qw/thumb/],
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Audio - The base class for Telegram 'Audio' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'Audio' type objects.

See L<https://core.telegram.org/bots/api#audio> for details of the
attributes available for L<Teapot::Bot::Object::Audio> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
