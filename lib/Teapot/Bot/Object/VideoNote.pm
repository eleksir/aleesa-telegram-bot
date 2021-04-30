package Teapot::Bot::Object::VideoNote;
# ABSTRACT: The base class for Telegram 'VideoNote' type objects


use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PhotoSize;

$Teapot::Bot::Object::VideoNote::VERSION = '0.022';

has 'file_id';
has 'file_unique_id';
has 'length';
has 'duration';
has 'mime_type';
has 'thumb'; #PhotoSize
has 'file_size';

sub fields {
  return {
           scalar                           => [qw/file_id file_unique_id length duration mime_type file_size/],
           'Teapot::Bot::Object::PhotoSize' => [qw/thumb /],
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::VideoNote - The base class for Telegram 'VideoNote' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'VideoNote' type object.

See L<https://core.telegram.org/bots/api#videonote> for details of the
attributes available for L<Teapot::Bot::Object::VideoNote> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
