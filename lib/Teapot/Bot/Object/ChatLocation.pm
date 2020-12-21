package Teapot::Bot::Object::ChatLocation;
# ABSTRACT: The base class for Telegram message 'ChatLocation' type.

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ChatLocation::VERSION = '0.022';

has 'location';
has 'address';

sub fields {
  return {
    'Teapot::Bot::Object::Location' => [qw/location/],
    'scalar'                        => [qw/address/],
  };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatLocation - The base class for Telegram message 'ChatLocation' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'ChatLocation' type.

See L<https://core.telegram.org/bots/api#chatlocation> for details of the
attributes available for L<Teapot::Bot::Object::ChatLocation> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
