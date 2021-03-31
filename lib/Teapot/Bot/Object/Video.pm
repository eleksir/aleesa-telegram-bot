package Teapot::Bot::Object::Video;
# ABSTRACT: The base class for Telegram 'Video' object.

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PhotoSize;

$Teapot::Bot::Object::Video::VERSION = '0.022';

has 'file_id';
has 'file_unique_id';
has 'width';
has 'height';
has 'duration';
has 'thumb';     # Optional. Video thumbnail
has 'file_name'; # Optional. Original filename as defined by sender
has 'mime_type'; # Optional. Mime type of a file as defined by sender
has 'file_size'; # Optional. File size

sub fields {
  return {
           scalar                           => [qw/file_id file_unique_id width height duration file_name mime_type
                                                   file_size/],
           'Teapot::Bot::Object::PhotoSize' => [qw/thumb/]
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Video - The base class for Telegram 'Video' object

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'Video' object.

See L<https://core.telegram.org/bots/api#video> for details of the
attributes available for L<Teapot::Bot::Object::Video> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
