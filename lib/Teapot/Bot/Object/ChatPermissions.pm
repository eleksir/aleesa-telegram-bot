package Teapot::Bot::Object::ChatPermissions;
# ABSTRACT: The base class for Telegram 'ChatPermissions' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ChatPermissions::VERSION = '0.022';

# all fields are optional
# N.B. Some of the fields "overlaps" other, so in order to guess valid set of permissions you should check all of them
has 'can_send_messages';         # True, if the user is allowed to send text messages, contacts, locations and venues
has 'can_send_media_messages';   # True, if the user is allowed to send audios, documents, photos, videos, video notes
                                 # and voice notes, implies can_send_messages
has 'can_send_polls';            # True, if the user is allowed to send polls, implies can_send_messages
has 'can_send_other_messages';   # True, if the user is allowed to send animations, games, stickers and use inline bots,
                                 # implies can_send_media_messages
has 'can_add_web_page_previews'; # True, if the user is allowed to add web page previews to their messages, implies
                                 # can_send_media_messages
has 'can_change_info';           # True, if the user is allowed to change the chat title, photo and other settings.
                                 # Ignored in public supergroups
has 'can_invite_users';          # True, if the user is allowed to invite new users to the chat
has 'can_pin_messages';          # True, if the user is allowed to pin messages. Ignored in public supergroups

sub fields {
  return {
          'scalar'                           => [qw/can_send_messages can_send_media_messages can_send_polls
                                                    can_send_other_messages can_add_web_page_previews can_change_info
                                                    can_invite_users can_pin_messages/]
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatPermissions - The base class for Telegram 'ChatPermissions' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'ChatPermissions' type objects.

See L<https://core.telegram.org/bots/api#chatpermissions> for details of the
attributes available for L<Teapot::Bot::Object::ChatPermissions> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
