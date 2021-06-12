package Teapot::Bot::Object::ChatMemberUpdated;
# ABSTRACT: The base class for Telegram 'ChatMemberUpdated' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::Chat;
use Teapot::Bot::Object::User;
use Teapot::Bot::Object::ChatMember;
use Teapot::Bot::Object::ChatInviteLink;
use Teapot::Bot::Object::Voice;

$Teapot::Bot::Object::ChatMemberUpdated::VERSION = '0.022';

has 'chat';
has 'from';
has 'date';
has 'old_chat_member';
has 'new_chat_member';
has 'text';            # Undocumented as of Bot API 5.2
has 'voice';           # Undocumented as of Bot API 5.2
has 'invite_link';     # Optional. Chat invite link, which was used by the user to join the chat; for joining by
                       # invite link events only.

sub fields {
  return {
          'Teapot::Bot::Object::Chat'           => [qw/chat/],
          'Teapot::Bot::Object::User'           => [qw/from/],
          'scalar'                              => [qw/date text/],
          'Teapot::Bot::Object::ChatMember'     => [qw/old_chat_member new_chat_member/],
          'Teapot::Bot::Object::Voice'          => [qw/voice/],
          'Teapot::Bot::Object::ChatInviteLink' => [qw/invite_link/]
        };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatMemberUpdated - The base class for Telegram 'ChatMemberUpdated' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'ChatMemberUpdated' type objects.

See L<https://core.telegram.org/bots/api#chatmemberupdated> for details of the
attributes available for L<Teapot::Bot::Object::ChatMemberUpdated> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 by Sergei Fedosov <eleksir@gmail.com>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
