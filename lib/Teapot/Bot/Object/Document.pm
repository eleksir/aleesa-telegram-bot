package Teapot::Bot::Object::Document;
$Teapot::Bot::Object::Document::VERSION = '0.021';
# ABSTRACT: The base class for Telegram 'Document' objects


use Mojo::Base 'Teapot::Bot::Object::Base';

use Teapot::Bot::Object::PhotoSize;

has 'file_id';
has 'thumb'; #PhotoSize
has 'file_name';
has 'mime_type';
has 'file_size';

sub fields {
  return { scalar => [qw/file_id file_name mime_type file_size/],
           'Teapot::Bot::Object::PhotoSize' => [qw/thumb/]
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Document - The base class for Telegram 'Document' objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION

See L<https://core.telegram.org/bots/api#document> for details of the
attributes available for L<Teapot::Bot::Object::Document> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
