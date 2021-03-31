package Teapot::Bot::Object::VoiceChatStarted;
# ABSTRACT: The base class for Telegram message 'VoiceChatStarted' type.

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::VoiceChatStarted::VERSION = '0.022';

# This object represents a service message about a voice chat started in the chat. Currently holds no information.
has 'stub';

sub fields {
  return { scalar => [qw/stub/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::VoiceChatStarted - The base class for Telegram message 'VoiceChatStarted' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'VoiceChatStarted' type.

See L<https://core.telegram.org/bots/api#voicechatstarted> for details of the
attributes available for L<Teapot::Bot::Object::VoiceChatStarted> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
