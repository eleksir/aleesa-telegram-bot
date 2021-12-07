package Teapot::Bot::Object::Chat;
# ABSTRACT: The base class for Telegram 'Chat' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::ChatPhoto;
use Teapot::Bot::Object::Message;
use Teapot::Bot::Object::ChatPermissions;
use Teapot::Bot::Object::ChatLocation;

$Teapot::Bot::Object::Chat::VERSION = '0.022';

has 'id';
has 'type';
has 'title';                    # Optional.
has 'username';                 # Optional.
has 'first_name';               # Optional.
has 'last_name';                # Optional.
has 'photo';                    # Teapot::Bot::Object::ChatPhoto. Optional. Returned only in getChat.
has 'bio';                      # Optional. Bio of the other party in a private chat. Returned only in getChat.
has 'has_private_forwards';     # Optional. True, if privacy settings of the other party in the private chat allows to
                                # use tg://user?id=<user_id> links only in chats with the user.
                                # Returned only in getChat.
has 'description';              # Optional. Returned only in getChat.
has 'invite_link';              # Optional. Returned only in getChat.
has 'pinned_message';           # Teapot::Bot::Object::Message
has 'permissions';              # Teapot::Bot::Object::ChatPermissions. Optional. Default chat member permissions, for
                                # groups and supergroups. Returned only in getChat.
has 'slow_mode_delay';          # Optional. Returned only in getChat.
has 'message_auto_delete_time'; # Optional. The time after which all messages sent to the chat will be automatically
                                # deleted; in seconds. Returned only in getChat.
has 'has_protected_content';    # Optional. True, if messages from the chat can't be forwarded to other chats.
                                # Returned only in getChat.
has 'sticker_set_name';         # Optional. Returned only in getChat.
has 'can_set_sticker_set';      # Optional. Returned only in getChat.
has 'linked_chat_id';           # Optional. greater than 32 bits, smaller than 52 bits
has 'location';                 # Optional. Returned only in getChat.

sub fields {
  return {
          'scalar'                               => [qw/id type title username first_name last_name bio
                                                        has_private_forwards description invite_link slow_mode_delay
                                                        message_auto_delete_time has_protected_content
                                                        sticker_set_name can_set_sticker_set linked_chat_id/],
          'Teapot::Bot::Object::ChatPhoto'       => [qw/photo/],
          'Teapot::Bot::Object::Message'         => [qw/pinned_message/],
          'Teapot::Bot::Object::ChatPermissions' => [qw/permissions/],
          'Teapot::Bot::Object::ChatLocation'    => [qw/location/],
        };
}


sub is_user {
  return shift->id > 0;
}


sub is_group {
  return shift->id < 0;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Chat - The base class for Telegram 'Chat' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'Chat' type objects.

See L<https://core.telegram.org/bots/api#chat> for details of the
attributes available for L<Teapot::Bot::Object::Chat> objects.

=head1 METHODS

=head2 is_user

Returns true is this is a chat is a single user.

=head2 is_group

Returns true if this is a chat is a group.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
