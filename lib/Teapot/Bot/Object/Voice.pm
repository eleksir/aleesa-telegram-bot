package Teapot::Bot::Object::Voice;
# ABSTRACT: The base class for Telegram 'Voice' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Voice::VERSION = '0.022';

has 'file_id';
has 'file_unique_id';
has 'duration';
has 'mime_type';
has 'file_size';

sub fields {
  return { scalar => [qw/file_id file_unique_id duration mime_type file_size/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Voice - The base class for Telegram 'Voice' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'Voice' type objects.

See L<https://core.telegram.org/bots/api#voice> for details of the
attributes available for L<Teapot::Bot::Object::Voice> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
