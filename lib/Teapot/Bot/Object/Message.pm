package Teapot::Bot::Object::Message;
# ABSTRACT: The base class for the Telegram type "Message".

use Mojo::Base 'Teapot::Bot::Object::Base';

use Teapot::Bot::Object::User;
use Teapot::Bot::Object::Chat;
use Teapot::Bot::Object::ChatMember;
use Teapot::Bot::Object::ChatPermissions;
use Teapot::Bot::Object::MessageEntity;
use Teapot::Bot::Object::Audio;
use Teapot::Bot::Object::Document;
use Teapot::Bot::Object::Animation;
use Teapot::Bot::Object::Game;
use Teapot::Bot::Object::PhotoSize;
use Teapot::Bot::Object::Sticker;
use Teapot::Bot::Object::Video;
use Teapot::Bot::Object::Voice;
use Teapot::Bot::Object::VideoNote;
use Teapot::Bot::Object::Contact;
use Teapot::Bot::Object::Location;
use Teapot::Bot::Object::Poll;
use Teapot::Bot::Object::Location;
use Teapot::Bot::Object::PhotoSize;
use Teapot::Bot::Object::Invoice;
use Teapot::Bot::Object::Venue;
use Teapot::Bot::Object::SuccessfulPayment;
use Teapot::Bot::Object::PassportData;
use Teapot::Bot::Object::InlineKeyboardMarkup;
use Teapot::Bot::Object::ProximityAlertTriggered;
use Teapot::Bot::Object::Dice;
use Teapot::Bot::Object::MessageAutoDeleteTimerChanged;
use Teapot::Bot::Object::VoiceChatScheduled;
use Teapot::Bot::Object::VoiceChatStarted;
use Teapot::Bot::Object::VoiceChatEnded;
use Teapot::Bot::Object::VoiceChatParticipantsInvited;

use Data::Dumper;
use Carp qw(cluck);

$Teapot::Bot::Object::Message::VERSION = '0.022';

# basic message stuff
has 'message_id';
has 'from';  # User
has 'sender_chat';  # Chat
has 'date';
has 'chat';  # Chat
has 'forward_from'; # User
has 'forward_from_chat'; # Chat
has 'forward_from_message_id';
has 'forward_signature';
has 'forward_sender_name';
has 'forward_date';
has 'is_automatic_forward';
has 'reply_to_message'; # Message
has 'via_bot'; # User
has 'edit_date';
has 'has_protected_content';
has 'media_group_id';
has 'author_signature';
has 'text';
has 'entities'; # Array of MessageEntity
has 'animation'; # Animation
has 'audio'; # Audio
has 'document'; # Document
has 'photo'; # Array of PhotoSize
has 'sticker';  # Sticker
has 'video'; # Video
has 'video_note'; # VideoNote
has 'voice'; # Voice
has 'caption';
has 'caption_entities'; # Array of MessageEntity
has 'contact'; # Contact
has 'dice';
has 'game';
has 'poll'; # Poll
has 'venue'; # Venue
has 'location'; # Location
has 'new_chat_members'; # Array of User
has 'left_chat_member'; # User
has 'new_chat_title';
has 'new_chat_photo'; # Array of PhotoSize
has 'delete_chat_photo';
has 'group_chat_created';
has 'supergroup_chat_created';
has 'channel_chat_created';
has 'message_auto_delete_timer_changed'; # Optional. Service message: auto-delete timer settings changed in the chat
has 'migrate_to_chat_id';
has 'migrate_from_chat_id';
has 'pinned_message'; # Message
has 'invoice'; # Invoice
has 'successful_payment'; # SuccessfulPayment
has 'connected_website';
has 'passport_data'; # PassportData
has 'proximity_alert_triggered';
has 'voice_chat_scheduled'; # Optional. Service message: voice chat scheduled
has 'voice_chat_started'; # Optional. Service message: voice chat started
has 'voice_chat_ended'; # Optional. Service message: voice chat ended
has 'voice_chat_participants_invited'; # Optional. Service message: new participants invited to a voice chat
has 'reply_markup'; # Array of InlineKeyboardMarkup

sub fields {
  return {
          'scalar'                                      => [qw/message_id date forward_from_message_id
                                                            forward_signature forward_sender_name
                                                            forward_date is_automatic_forward edit_date has_protected_content
                                                            media_group_id author_signature text caption
                                                            new_chat_title delete_chat_photo
                                                            group_chat_created supergroup_chat_created
                                                            channel_chat_created migrate_to_chat_id
                                                            migrate_from_chat_id connected_website/],
          'Teapot::Bot::Object::User'                 => [qw/from forward_from via_bot new_chat_members left_chat_member /],

          'Teapot::Bot::Object::Chat'                 => [qw/sender_chat chat forward_from_chat/],
          'Teapot::Bot::Object::Message'              => [qw/reply_to_message pinned_message/],
          'Teapot::Bot::Object::MessageEntity'        => [qw/entities caption_entities /],

          'Teapot::Bot::Object::Audio'                => [qw/audio/],
          'Teapot::Bot::Object::Document'             => [qw/document/],
          'Teapot::Bot::Object::Animation'            => [qw/animation/],
          'Teapot::Bot::Object::Game'                 => [qw/game/],
          'Teapot::Bot::Object::PhotoSize'            => [qw/photo new_chat_photo/],
          'Teapot::Bot::Object::Sticker'              => [qw/sticker/],
          'Teapot::Bot::Object::Video'                => [qw/video/],
          'Teapot::Bot::Object::Voice'                => [qw/voice/],
          'Teapot::Bot::Object::VideoNote'            => [qw/video_note/],

          'Teapot::Bot::Object::Contact'              => [qw/contact/],
          'Teapot::Bot::Object::Location'             => [qw/location/],
          'Teapot::Bot::Object::Venue'                => [qw/venue/],

          'Teapot::Bot::Object::Poll'                 => [qw/poll/],

          'Teapot::Bot::Object::Invoice'              => [qw/invoice/],
          'Teapot::Bot::Object::SuccessfulPayment'    => [qw/successful_payment/],
          'Teapot::Bot::Object::PassportData'         => [qw/passport_data/],
          'Teapot::Bot::Object::InlineKeyboardMarkup' => [qw/reply_markup/],
          'Teapot::Bot::Object::ProximityAlertTriggered' => [qw/proximity_alert_triggered/],
          'Teapot::Bot::Object::Dice'                 => [qw/dice/],
          'Teapot::Bot::Object::MessageAutoDeleteTimerChanged' => [qw/message_auto_delete_timer_changed/],
          'Teapot::Bot::Object::VoiceChatScheduled'   => [qw/voice_chat_scheduled/],
          'Teapot::Bot::Object::VoiceChatStarted'     => [qw/voice_chat_started/],
          'Teapot::Bot::Object::VoiceChatEnded'       => [qw/voice_chat_ended/],
          'Teapot::Bot::Object::VoiceChatParticipantsInvited' => [qw/voice_chat_participants_invited/],
  };
}

sub arrays {
  return qw/photo entities caption_entities new_chat_members new_chat_photo/;
}


sub reply {
  my $self = shift;
  my $text = shift;

  my $chatid = $self->chat->id;

  if (Teapot::Bot::Object::ChatPermissions::canTalk($self, $chatid)) {
    return $self->_brain->sendMessage({chat_id => $chatid, text => $text});
  }

  return {'error' => 1};
}

sub replyMd {
  my $self = shift;
  my $text = shift;

  my $chatid = $self->chat->id;

  if (Teapot::Bot::Object::ChatPermissions::canTalk ($self, $chatid)) {
    my $send_args;
    $send_args->{text} = $text;
    $send_args->{parse_mode} = 'Markdown';
    $send_args->{chat_id} = $chatid;

    return $self->_brain->sendMessage($send_args);
  }

  return {'error' => 1};
}

sub typing {
  my $self = shift;

  my $chatid = $self->chat->id;

  if (Teapot::Bot::Object::ChatPermissions::canTalk ($self, $chatid)) {
    return $self->_brain->sendChatAction({chat_id => $chatid});
  }

  return {'error' => 1};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Message - The base class for the Telegram type "Message"

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for the Telegram type "Message".

See L<https://core.telegram.org/bots/api#message> for details of the
attributes available for L<Teapot::Bot::Object::Message> objects.

=head1 METHODS

=head2 reply

A convenience method to reply to a message with text.

Will return the L<Teapot::Bot::Object::Message> object representing the message
sent.

=head2 typing

Sends notification to chat that bot is "typing" something.

Returns nothing that should be checked.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
