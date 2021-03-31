package Teapot::Bot::Object::Audio;
# ABSTRACT: The base class for Telegram 'Audio' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Audio::VERSION = '0.022';

has 'file_id';
has 'file_unique_id';
has 'duration';
has 'performer'; # Optional. Performer of the audio as defined by sender or by audio tags
has 'title';     # Optional. Title of the audio as defined by sender or by audio tags
has 'file_name'; # Optional. Original filename as defined by sender
has 'mime_type'; # Optional. MIME type of the file as defined by sender
has 'file_size'; # Optional. File size
has 'thumb';     # Optional. Thumbnail of the album cover to which the music file belongs

sub fields {
  return { scalar                           => [qw/file_id file_unique_id duration performer title file_name mime_type
                                                   file_size/],
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
