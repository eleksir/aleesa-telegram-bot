package Teapot::Bot::Object::ChatPhoto;
# ABSTRACT: The base class for Telegram 'ChatPhoto' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ChatPhoto::VERSION = '0.022';

has 'small_file_id';
has 'small_file_unique_id';
has 'big_file_id';
has 'big_file_unique_id';

sub fields {
  return {
           'scalar' => [qw/small_file_id small_file_unique_id big_file_id big_file_unique_id/],
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatPhoto - The base class for Telegram 'ChatPhoto' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'ChatPhoto' type objects.

See L<https://core.telegram.org/bots/api#chatphoto> for details of the
attributes available for L<Teapot::Bot::Object::ChatPhoto> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
