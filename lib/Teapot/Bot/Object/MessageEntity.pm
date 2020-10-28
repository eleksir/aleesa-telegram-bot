package Teapot::Bot::Object::MessageEntity;
$Teapot::Bot::Object::MessageEntity::VERSION = '0.021';
# ABSTRACT: The base class for Telegram 'MessageEntity' type objects


use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::User;

has 'type';
has 'offset';
has 'length';
has 'url';
has 'user'; #User

sub fields {
  return {
          'scalar'                      => [qw/type offset length url/],
          'Teapot::Bot::Object::User' => [qw/user/],
        };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::MessageEntity - The base class for Telegram 'MessageEntity' type objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION

See L<https://core.telegram.org/bots/api#messageentity> for details of the
attributes available for L<Teapot::Bot::Object::MessageEntity> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
