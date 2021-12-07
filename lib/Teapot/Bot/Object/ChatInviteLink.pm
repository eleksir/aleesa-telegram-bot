package Teapot::Bot::Object::ChatInviteLink;
# ABSTRACT: The base class for Telegram message 'ChatInviteLink' type.

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::User;

$Teapot::Bot::Object::ChatInviteLink::VERSION = '0.022';

has 'invite_link';
has 'creator';
has 'creates_join_request';
has 'is_primary';
has 'is_revoked';
has 'name';
has 'expire_date';  # Optional. Point in time (Unix timestamp) when the link will expire or has been expired
has 'member_limit'; # Optional. Maximum number of users that can be members of the chat simultaneously after joining
                    # the chat via this invite link; 1-99999
has 'pending_join_request_count';

sub fields {
  return {
    'scalar'                    => [qw/invite_link creates_join_request is_primary is_revoked name expire_date
                                       member_limit pending_join_request_count/],
    'Teapot::Bot::Object::User' => [qw/creator/],
  };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ChatInviteLink - The base class for Telegram message 'ChatInviteLink' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'ChatInviteLink' type.

See L<https://core.telegram.org/bots/api#chatinvitelink> for details of the
attributes available for L<Teapot::Bot::Object::ChatInviteLink> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
