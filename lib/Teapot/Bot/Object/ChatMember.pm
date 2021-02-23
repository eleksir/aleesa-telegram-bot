package Teapot::Bot::Object::ChatMember;
# ABSTRACT: The base class for Telegram 'ChatMember' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::User;
use Carp qw(cluck);

$Teapot::Bot::Object::ChatMember::VERSION = '0.022';

has 'user';
has 'status';
has 'custom_title';              # optional. Owner and administrators only.
has 'is_anonymous';              # Optional. Owner and administrators only.

has 'can_be_edited';             # optional. Administrators only.
has 'can_post_messages';         # optional. Administrators only.
has 'can_edit_messages';         # optional. Administrators only.
has 'can_delete_messages';       # optional. Administrators only.
has 'can_restrict_members';      # optional. Administrators only.
has 'can_promote_members';       # optional. Administrators only.
has 'can_change_info';           # optional. Administrators and restricted only.
has 'can_invite_users';          # optional. Administrators and restricted only.
has 'can_pin_messages';          # optional. Administrators and restricted only.
has 'is_member';                 # optional. Restricted only.
has 'can_send_messages';         # optional. Restricted only.
has 'can_send_media_messages';   # optional. Restricted only.
has 'can_send_polls';            # optional. Restricted only.
has 'can_send_other_messages';   # optional. Restricted only.
has 'can_add_web_page_previews'; # optional. Restricted only.
has 'until_date';                # optional. Restricted and kicked only.

sub fields {
  return {
          'scalar'                    => [qw/status custom_title is_anonymous can_be_edited can_post_messages can_edit_messages
                                             can_delete_messages can_restrict_members can_promote_members can_change_info
                                             can_invite_users can_pin_messages is_member can_send_messages
                                             can_send_media_messages can_send_polls can_send_other_messages can_add_web_page_previews until_date/],
          'Teapot::Bot::Object::User' => [qw/user/],
        };
}


sub canDeleteMessage {
  my $self = shift;
  my $chatid = shift;

  my $can_delete = 0;

  if ($chatid < 0) {
    # group chat
    my $chatobj = $self->getChat ({ 'chat_id' => $chatid });

    # on api error, keep silence
    unless ($chatobj) {
      cluck "Unable to get chat info for $chatid from telegram API";
      return 0;
    }

    my $myObj = $self->getMe ();

    # on api error, keep silence
    unless ($chatobj) {
      cluck "Unable to get chat info for $chatid from telegram API";
      return 0;
    }

    my $myid = $myObj->id;
    my $me = $self->getChatMember ({ 'chat_id' => $chatid, 'user_id' => $myid });

    # on api error, keep silence
    unless ($me) {
      cluck 'Unable to get chat info for bot itself from telegram API';
      return 0;
    }

    # bot can delete msg if it is group and it is admin there.
    if ($chatobj->{'type'} eq 'group') {
      if ($me->{'status'} eq 'administrator') {
        $can_delete = 1;
      }
    # in supergroup bot must be granted with can_delete_messages
    } elsif (($chatobj->{'type'} eq 'supergroup') || ($chatobj->{'type'} eq 'channel')) {
      if ($me->{'can_delete_messages'}) {
        $can_delete = 1;
      }
    }
  } else {
    # 1 on 1 chat with user
    $can_delete = 1;
  }

  return $can_delete;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatMember - The base class for Telegram 'ChatMember' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'ChatMember' type objects.

See L<https://core.telegram.org/bots/api#chatmember> for details of the
attributes available for L<Teapot::Bot::Object::ChatMember> objects.

=head1 METHODS

=head2 canDeleteMessage

A convenience method to check if bot can delete message in given conversation.

Returns true if the bot can delete the message in given conversation, otherwise false.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 by Sergei Fedosov <eleksir@gmail.com>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
