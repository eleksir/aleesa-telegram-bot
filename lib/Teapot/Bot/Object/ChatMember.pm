package Teapot::Bot::Object::ChatMember;
# ABSTRACT: The base class for Telegram 'ChatMember' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::User;

$Teapot::Bot::Object::ChatMember::VERSION = '0.021';

has 'user';
has 'status';
has 'custom_title';              # optional. Owner and administrators only.
has 'until';                     # optional. Restricted and kicked only.
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

sub fields {
  return {
          'scalar'                    => [qw/status custom_title until can_be_edited can_post_messages can_edit_messages
                                             can_delete_messages can_restrict_members can_promote_members can_change_info
                                             can_invite_users can_pin_messages is_member can_send_messages
                                             can_send_media_messages can_send_polls can_send_other_messages can_add_web_page_previews/],
          'Teapot::Bot::Object::User' => [qw/user/],
        };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatMember - The base class for Telegram 'ChatMember' type objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION
The base class for Telegram 'ChatMember' type objects.

See L<https://core.telegram.org/bots/api#chatmember> for details of the
attributes available for L<Teapot::Bot::Object::ChatMember> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 by Sergei Fedosov <eleksir@gmail.com>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
