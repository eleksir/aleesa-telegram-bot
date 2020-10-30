package Teapot::Bot::Brain;

# ABSTRACT: A base class to make your very own Telegram bot

use Mojo::Base -base;

use strict;
use warnings;

use Mojo::IOLoop;
use Mojo::UserAgent;
use Carp qw/croak, cluck, confess/; # use croak where we return error up to app that supply something wrong
                                    # use cluck where we want to say that something bad but non-critical happen in
                                    #     lower layer (Mojo loop)
                                    # use confess where we want to say that fatal error happen in lower layer (Mojo loop)
use Log::Any;
use Data::Dumper;

use Teapot::Bot::Object::Message;

$Teapot::Bot::Brain::VERSION = '0.021';

# base class for building telegram robots with Mojolicious
has longpoll_time => 60;
has ua         => sub { Mojo::UserAgent->new->inactivity_timeout(shift->longpoll_time + 15) };
has token      => sub { croak "you need to supply your own token"; };

has tasks      => sub { [] };
has listeners  => sub { [] };

has log        => sub { Log::Any->get_logger };


sub add_repeating_task {
  my $self    = shift;
  my $seconds = shift;
  my $task    = shift;

  my $repeater = sub {

    # Perform operation every $seconds seconds
    my $last_check = time();
    Mojo::IOLoop->recurring(0.1 => sub {
                              my $loop = shift;
                              my $now  = time();
                              return unless ($now - $last_check) >= $seconds;
                              $last_check = $now;
                              $task->($self);
                            });
  };

  # keep a copy
  push @{ $self->tasks }, $repeater;

  # kick it off
  $repeater->();
  return;
}


sub add_listener {
  my $self    = shift;
  my $coderef = shift;

  push @{ $self->listeners }, $coderef;
  return;
}

sub init {
  die "init was not overridden!";
}


sub think {
  my $self = shift;
  $self->init();

  $self->_add_getUpdates_handler;
  Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
  return;
}



sub getMe {
  my $self = shift;
  my $token = $self->token || croak "no token?";

  my $url = "https://api.telegram.org/bot${token}/getMe";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::User->create_from_hash($api_response, $self);
  }
  else {
    return {"error" => 1};
  }
}


sub getChatMember {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};
  croak "no chat_id supplied" unless $args->{chat_id};
  croak "no user_id supplied" unless $args->{user_id};
  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{user_id} = $args->{user_id};

  my $token = $self->token || croak "no token?";

  my $url = "https://api.telegram.org/bot${token}/getChatMember";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::ChatMember->create_from_hash($api_response, $self);
  }
  else {
    return {"error" => 1};
  }
}


sub getChat {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};
  croak "no chat_id supplied" unless $args->{chat_id};
  $send_args->{chat_id} = $args->{chat_id};

  my $token = $self->token || croak "no token?";

  my $url = "https://api.telegram.org/bot${token}/getChat";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::Chat->create_from_hash($api_response, $self);
  }
  else {
    return {"error" => 1};
  }
}


sub sendMessage {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};
  croak "no chat_id supplied in sendMessage" unless $args->{chat_id};
  $send_args->{chat_id} = $args->{chat_id};

  croak "no text supplied in sendMessage"    unless $args->{text};
  $send_args->{text}    = $args->{text};

  # these are optional, send if they are supplied
  $send_args->{parse_mode} = $args->{parse_mode} if exists $args->{parse_mode};
  $send_args->{disable_web_page_preview} = $args->{disable_web_page_preview} if exists $args->{disable_web_page_preview};
  $send_args->{disable_notification} = $args->{disable_notification} if exists $args->{disable_notification};
  $send_args->{reply_to_message_id}  = $args->{reply_to_message_id}  if exists $args->{reply_to_message_id};

  # check reply_markup is the right kind
  if (exists $args->{reply_markup}) {
    my $reply_markup = $args->{reply_markup};
      croak "Incorrect reply_markup in sendMessage" if ( ref($reply_markup) ne 'Teapot::Bot::Object::InlineKeyboardMarkup' &&
           ref($reply_markup) ne 'Teapot::Bot::Object::ReplyKeyboardMarkup'  &&
           ref($reply_markup) ne 'Teapot::Bot::Object::ReplyKeyboardRemove'  &&
           ref($reply_markup) ne 'Teapot::Bot::Object::ForceReply' );
    $send_args->{reply_markup} = $reply_markup;
  }

  my $token = $self->token || croak "no token in sendMessage?";
  my $url = "https://api.telegram.org/bot${token}/sendMessage";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Message->create_from_hash($api_response, $self);
  }
  else {
    return {"error" => 1};
  }
}


sub forwardMessage {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};
  croak "no chat_id supplied in forwardMessage" unless $args->{chat_id};
  $send_args->{chat_id} = $args->{chat_id};

  croak "no from_chat_id supplied in forwardMessage"    unless $args->{from_chat_id};
  $send_args->{from_chat_id}    = $args->{from_chat_id};

  croak "no message_id supplied in forwardMessage"    unless $args->{message_id};
  $send_args->{message_id}    = $args->{message_id};

  # these are optional, send if they are supplied
  $send_args->{disable_notification} = $args->{disable_notification} if exists $args->{disable_notification};

  my $token = $self->token || croak "no token in forwardMessage?";
  my $url = "https://api.telegram.org/bot${token}/forwardMessage";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Message->create_from_hash($api_response, $self);
  }
  else {
    return {"error" => 1};
  }
}


sub sendPhoto {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  croak "no chat_id supplied" unless $args->{chat_id};
  $send_args->{chat_id} = $args->{chat_id};

  # photo can be a string (which might be either a URL for telegram servers
  # to fetch, or a file_id string) or a file on disk to upload - we need
  # to handle that last case here as it changes the way we create the HTTP
  # request
  croak "no photo supplied in sendPhoto" unless $args->{photo};
  if (-e $args->{photo}) {
    $send_args->{photo} = { photo => { file => $args->{photo} } };
  }
  else {
    $send_args->{photo} = $args->{photo};
  }

  my $token = $self->token || croak "no token in sendPhoto?";
  my $url = "https://api.telegram.org/bot${token}/sendPhoto";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Message->create_from_hash($api_response, $self);
  }
  else {
    return {"error" => 1};
  }
}


sub sendChatAction {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  croak "no chat_id supplied in sendChatAction" unless $args->{chat_id};
  $send_args->{chat_id} = $args->{chat_id};

  if ($args->{action} eq 'upload_photo') {
    $send_args->{action} = 'upload_photo';
  }
  elsif ($args->{action} eq 'record_video') {
    $send_args->{action} = 'record_video';
  }
  elsif ($args->{action} eq 'upload_video') {
    $send_args->{action} = 'upload_video';
  }
  elsif ($args->{action} eq 'record_audio') {
    $send_args->{action} = 'record_audio';
  }
  elsif ($args->{action} eq 'upload_audio') {
    $send_args->{action} = 'upload_audio';
  }
  elsif ($args->{action} eq 'upload_document') {
    $send_args->{action} = 'upload_document';
  }
  elsif ($args->{action} eq 'find_location') {
    $send_args->{action} = 'find_location';
  }
  elsif ($args->{action} eq 'record_video_note') {
    $send_args->{action} = 'record_video_note';
  }
  elsif ($args->{action} eq 'upload_video_note') {
    $send_args->{action} = 'upload_video_note';
  }
  else {
    $send_args->{action} = 'typing';
  }

  my $token = $self->token || croak "no token in sendChatAction?";
  my $url = "https://api.telegram.org/bot${token}/sendChatAction";
  my $api_response = $self->_post_request ($url, $send_args);

  return;
}


sub _add_getUpdates_handler {
  my $self = shift;

  my $http_active = 0;
  my $last_update_id = -1;
  my $token  = $self->token;

  Mojo::IOLoop->recurring(0.1 => sub {
    # do nothing if our previous longpoll is still going
    return if $http_active;

    my $offset = $last_update_id + 1;
    my $updateURL = "https://api.telegram.org/bot${token}/getUpdates?offset=${offset}&timeout=60";
    $http_active = 1;

    $self->ua->get($updateURL => sub {
      my ($ua, $tx) = @_;
      my $res = $tx->res->json;
      my $items = $res->{result};
      foreach my $item (@$items) {
        $last_update_id = $item->{update_id};
        $self->_process_message($item);
      }

      $http_active = 0;
    });
  });

  return;
}

# process a message which arrived via getUpdates
sub _process_message {
    my $self = shift;
    my $item = shift;

    my $update_id = $item->{update_id};
    # There can be several types of responses. But only one response.
    # https://core.telegram.org/bots/api#update
    my $update;
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{message}, $self)             if $item->{message};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{edited_message}, $self)      if $item->{edited_message};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{channel_post}, $self)        if $item->{channel_post};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{edited_channel_post}, $self) if $item->{edited_channel_post};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{poll}, $self)                if $item->{poll};

    # if we got to this point without creating a response, it must be a type we
    # don't handle yet
    if (! $update) {
      cluck "Do not know how to handle this update: " . Dumper($item);
    }

    foreach my $listener (@{ $self->listeners }) {
      # call the listener code, supplying ourself and the update
      $listener->($self, $update);
    }

    return;
}


sub _post_request {
  my $self = shift;
  my $url  = shift;
  my $form_args = shift || {};

  my $res = $self->ua->post($url, form => $form_args)->result;

  if ($res->is_success) { 
    return $res->json->{result};
  }
  elsif ($res->is_error) {
    # This can be non-fatal error: api change.
    cluck "Failed to post: " . $res->message;
    return 0; # to handle this as false in upper layers
  }
  else {
    # This must be something fatal for sure, because either is_success or is_error must be set by Mojo
    confess "Not sure what went wrong";
  }
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Brain - A base class to make your very own Telegram bot

=head1 VERSION

version 0.021

=head1 SYNOPSIS

  package MyApp::Coolbot;

  use Mojo::Base 'Teapot::Bot::Brain';

  has token       => 'token-you-got-from-@botfather';

  sub init {
      my $self = shift;
      $self->add_repeating_task(600, \&timed_task);
      $self->add_listener(\&respond_to_messages);
  }

Elsewhere....

  my $bot = MyApp::Coolbot->new();
  $bot->think;  # this will block unless there is already an event
                # loop running

=head1 DESCRIPTION

This base class makes it easy to create your own Bot classes that
interface with the Telegram Bot API.

Internally it uses the Mojo::IOLoop event loop to provide non-blocking
access to the Bot API, allowing your bot to listen for events via the
longpoll getUpdates API method and also trigger timed events that can
run without blocking.

As with any bot framework, the principle is that the framework allows you
to interact with other users on Telegram. The Telegram API provides a rich
set of typed objects. This framework will allow you to create those objects
to send into the API (for instance, sending text messages, sending photos,
and more) as well as call your code (via L<add_listener> when your bot
receives messages (which might be text, or images, and so on).

How bots work with Telegram is out of scope for this document, a good
starting place is L<https://core.telegram.org/bots>.

=head1 METHODS

=head2 add_repeating_task

This method will add a sub to run every C<$seconds> seconds. Pass this method
two parameters, the number of seconds between executions, and the coderef to
execute.

Your coderef will be passed the L<Teapot::Bot::Brain> object when it is
executed.

=head2 add_listener

Respond to messages we receive. It takes a single argument, a coderef to execute
for each update that is sent to us. These are *typically* C<Teapot::Bot:Object::Message>
objects, though that is not the only type of update that may be sent (see
L<https://core.telegram.org/bots/api#update>).

Multiple listeners can be added, they will receive the incoming update in the order
that they are registered.

Any or all listeners can choose to ignore or take action on any particular update.

=head2 think

Start this bot thinking.

Calls your init method and then enters a blocking loop (unless a Mojo::IOLoop
is already running).

=head2 getMe

This is the wrapper around the C<getMe> API method. See
L<https://core.telegram.org/bots/api#getme>.

Takes no arguments, and returns the L<Teapot::Bot::Object::User> that
represents this bot.

On error returns hash reference with error set to 1

=head2 getChatMember

This is the wrapper around the C<getChatMember> API method. See
L<https://core.telegram.org/bots/api#getchatmember>.

Takes chat_id, and user_id as arguments.

Returns the L<Teapot::Bot::Object::ChatMember> that represents properties
of Chat User.

On error returns hash reference with error set to 1

=head2 getChat

This is the wrapper around the C<getChat> API method. See
L<https://core.telegram.org/bots/api#getchat>.

Takes chat_id as argument.

Returns the L<Teapot::Bot::Object::Chat> that represents properties of Chat.

On error returns hash reference with error set to 1

=head2 sendMessage

See L<https://core.telegram.org/bots/api#sendmessage>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 forwardMessage

See L<https://core.telegram.org/bots/api#forwardmessage>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 sendPhoto

See L<https://core.telegram.org/bots/api#sendphoto>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 sendChatAction
See L<https://core.telegram.org/bots/api#sendchataction>.

Returns nothing, it's send-only method (Telegram API returns true on success)

=head1 SEE ALSO

=over 4

=item *

L<Mojolicious>

=item *

L<https://core.telegram.org/bots>

=back

=head1 Telegram Bot API methods

The following methods are relatively thin wrappers around the various
methods available in the Telgram Bot API to send messages and perform other
updates.

L<https://core.telegram.org/bots/api#available-methods>

They all return immediately with the corresponding Teapot::Bot::Object
subclass - consult the documenation for each below to see what to expect.

Note that not all methods have yet been implemented.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
