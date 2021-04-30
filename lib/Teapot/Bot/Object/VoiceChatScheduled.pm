package Teapot::Bot::Object::VoiceChatScheduled;
# ABSTRACT: The base class for Telegram message 'VoiceChatEnded' type.

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::VoiceChatScheduled::VERSION = '0.022';

# This object represents a service message about a voice chat started in the chat. Currently holds no information.
has 'start_date';

sub fields {
  return { scalar => [qw/start_date/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::VoiceChatScheduled - The base class for Telegram message 'VoiceChatScheduled' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'VoiceChatScheduled' type.

See L<https://core.telegram.org/bots/api#voicechatscheduled> for details of the
attributes available for L<Teapot::Bot::Object::VoiceChatScheduled> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
