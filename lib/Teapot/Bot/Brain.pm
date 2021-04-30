package Teapot::Bot::Brain;

# ABSTRACT: A base class to make your very own Telegram bot

use Mojo::Base -base;

use strict;
use warnings;
use English qw ( -no_match_vars );

use Mojo::IOLoop;
use Mojo::UserAgent;
use Carp qw/croak cluck confess/; # use croak where we return error up to app that supply something wrong
                                  # use cluck where we want to say that something bad but non-critical happen in
                                  #     lower layer (Mojo loop)
                                  # use confess where we want to say that fatal error happen in lower layer (Mojo loop)
use Log::Any;
use Data::Dumper;

use Teapot::Bot::Object::Message;
use Teapot::Bot::Object::Poll;
use Teapot::Bot::Object::PollAnswer;
use Teapot::Bot::Object::ChatMemberUpdated;
use Teapot::Bot::Object::User;
use Teapot::Bot::Object::Chat;
use Teapot::Bot::Object::ChatMember;
use Teapot::Bot::Object::ChatInviteLink;

$Teapot::Bot::Brain::VERSION = '0.022';

# base class for building telegram robots with Mojolicious
has longpoll_time => 60;
has ua            => sub { Mojo::UserAgent->new->inactivity_timeout(shift->longpoll_time + 15) };
has token         => sub { croak 'You need to supply your own token'; };

has tasks         => sub { [] };
has listeners     => sub { [] };

has log           => sub { Log::Any->get_logger };


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
                              return if ($now - $last_check) < $seconds;
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
  croak 'init() was not overridden!';
}


sub think {
  my $self = shift;
  $self->init();

  $self->_add_getUpdates_handler;
  do { Mojo::IOLoop->start } until Mojo::IOLoop->is_running;
  return;
}



sub getMe {
  my $self = shift;
  my $token = $self->token || croak 'No token supplied to getMe()?';

  my $url = "https://api.telegram.org/bot${token}/getMe";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::User->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}


sub getChatMember {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied to getChatMember()';
    return {'error' => 1};
  }

  unless ($args->{user_id}) {
    cluck 'No user_id supplied to getChatMember()';
    return {'error' => 1};
  }


  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{user_id} = $args->{user_id};

  my $token = $self->token || croak 'No token supplied to getChatMember?';

  my $url = "https://api.telegram.org/bot${token}/getChatMember";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::ChatMember->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}

sub kickChatMember {
  my $self = shift;
  my $args = shift || {};

  my $token = $self->token || croak 'No token supplied to kickChatMember?';
  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied to kickChatMember()';
    return {'error' => 1};
  }

  unless ($args->{user_id}) {
    cluck 'No user_id supplied to kickChatMember()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{user_id} = $args->{user_id};
  $send_args->{until_date} = $args->{until_date} if exists $args->{until_date};
  $send_args->{revoke_messages} = $args->{revoke_messages} if exists $args->{revoke_messages};

  my $url = "https://api.telegram.org/bot${token}/kickChatMember";
  my $api_response = $self->_post_request($url, $send_args);

  return;
}

sub unbanChatMember {
  my $self = shift;
  my $args = shift || {};

  my $token = $self->token || croak 'No token supplied to unbanChatMember?';
  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied to unbanChatMember()';
    return {'error' => 1};
  }

  unless ($args->{user_id}) {
    cluck 'No user_id supplied to unbanChatMember()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{user_id} = $args->{user_id};
  $send_args->{only_if_banned} = $args->{only_if_banned} if exists $args->{only_if_banned};

  my $url = "https://api.telegram.org/bot${token}/unbanChatMember";
  my $api_response = $self->_post_request($url, $send_args);

  return;
}


sub getChat {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied to getChat()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  my $token = $self->token || croak 'No token supplied to getChat()?';

  my $url = "https://api.telegram.org/bot${token}/getChat";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Chat->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}


sub leaveChat {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied to getChat()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  my $token = $self->token || croak 'No token supplied to getChat()?';

  my $url = "https://api.telegram.org/bot${token}/leaveChat";
  my $api_response = $self->_post_request($url, $send_args);

  return;
}


sub sendMessage {
  my $self = shift;
  my $args = shift || {};

  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in sendMessage()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  unless ($args->{text}) {
    cluck 'No text supplied in sendMessage()';
    return {'error' => 1};
  }

  $send_args->{text}    = $args->{text};

  # these are optional, send if they are supplied
  $send_args->{parse_mode} = $args->{parse_mode} if exists $args->{parse_mode};
  $send_args->{disable_web_page_preview} = $args->{disable_web_page_preview} if exists $args->{disable_web_page_preview};
  $send_args->{disable_notification} = $args->{disable_notification} if exists $args->{disable_notification};
  $send_args->{reply_to_message_id}  = $args->{reply_to_message_id}  if exists $args->{reply_to_message_id};

  # check reply_markup is the right kind
  if (exists $args->{reply_markup}) {
    my $reply_markup = $args->{reply_markup};

    if ( ref($reply_markup) ne 'Teapot::Bot::Object::InlineKeyboardMarkup' &&
           ref($reply_markup) ne 'Teapot::Bot::Object::ReplyKeyboardMarkup'  &&
             ref($reply_markup) ne 'Teapot::Bot::Object::ReplyKeyboardRemove'  &&
               ref($reply_markup) ne 'Teapot::Bot::Object::ForceReply' ) {
      cluck 'Incorrect reply_markup in sendMessage()';
      return {'error' => 1};
    }

    $send_args->{reply_markup} = $reply_markup;
  }

  my $token = $self->token || croak 'No token supplied to sendMessage()?';
  my $url = "https://api.telegram.org/bot${token}/sendMessage";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Message->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}


sub forwardMessage {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in forwardMessage()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  unless ($args->{from_chat_id}) {
    cluck 'No from_chat_id supplied in forwardMessage()';
    return {'error' => 1};
  }

  $send_args->{from_chat_id} = $args->{from_chat_id};

  unless ($args->{message_id}) {
    cluck 'No message_id supplied in forwardMessage()';
    return {'error' => 1};
  }

  $send_args->{message_id} = $args->{message_id};

  # these are optional, send if they are supplied
  $send_args->{disable_notification} = $args->{disable_notification} if exists $args->{disable_notification};

  my $token = $self->token || croak 'No token supplied to forwardMessage()?';
  my $url = "https://api.telegram.org/bot${token}/forwardMessage";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Message->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}

# TODO: Check that message is no older than 48 hrs
sub deleteMessage {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in deleteMessage()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  unless ($args->{message_id}) {
    cluck 'No message_id supplied in deleteMessage()';
    return {'error' => 1};
  }

  $send_args->{message_id} = $args->{message_id};

  my $token = $self->token || croak 'No token supplied to deleteMessage()?';

  if (Teapot::Bot::Object::ChatMember->canDeleteMessage($self, $args->{chat_id})) {
    my $url = "https://api.telegram.org/bot${token}/deleteMessage";
    $self->_post_request($url, $send_args);
  }
  else {
    return {'error' => 1};
  }

  return;
}


sub sendPhoto {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied to sendPhoto()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  # photo can be a string (which might be either a URL for telegram servers
  # to fetch, or a file_id string) or a file on disk to upload - we need
  # to handle that last case here as it changes the way we create the HTTP
  # request
  unless ($args->{photo}) {
    cluck 'No photo supplied in sendPhoto()';
    return {'error' => 1};
  }

  if (-e $args->{photo}) {
    $send_args->{photo} = { file => $args->{photo} };
  }
  else {
    $send_args->{photo} = $args->{photo};
  }

  my $token = $self->token || croak 'No token in sendPhoto()?';
  my $url = "https://api.telegram.org/bot${token}/sendPhoto";
  my $api_response = $self->_post_request($url, $send_args);

  if ($api_response) {
    return Teapot::Bot::Object::Message->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}


sub sendChatAction {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in sendChatAction()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  unless (defined $args->{action}) {
    $args->{action} = 'typing';
    $send_args->{action} = 'typing';
  }

  if ($args->{action} eq 'upload_photo') {
    $send_args->{action} = 'upload_photo';
  }
  elsif ($args->{action} eq 'record_video') {
    $send_args->{action} = 'record_video';
  }
  elsif ($args->{action} eq 'upload_video') {
    $send_args->{action} = 'upload_video';
  }
  elsif ($args->{action} eq 'record_voice') {
    $send_args->{action} = 'record_voice';
  }
  elsif ($args->{action} eq 'upload_voice') {
    $send_args->{action} = 'upload_voice';
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

  my $token = $self->token || croak 'No token in sendChatAction()?';
  my $url = "https://api.telegram.org/bot${token}/sendChatAction";
  my $api_response = $self->_post_request ($url, $send_args);

  return;
}

sub exportChatInviteLink {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  my $token = $self->token || croak 'No token supplied to createChatInviteLink()?';

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in createChatInviteLink()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};

  my $url = "https://api.telegram.org/bot${token}/exportChatInviteLink";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return $api_response;
  }
  else {
    return {'error' => 1};
  }
}

sub createChatInviteLink {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  my $token = $self->token || croak 'No token supplied to createChatInviteLink()?';

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in createChatInviteLink()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{expire_date} = $args->{expire_date} if exists $args->{expire_date};
  $send_args->{member_limit} = $args->{member_limit} if exists $args->{member_limit};

  my $url = "https://api.telegram.org/bot${token}/createChatInviteLink";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::ChatInviteLink->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}

sub editChatInviteLink {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  my $token = $self->token || croak 'No token supplied to editChatInviteLink()?';

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in editChatInviteLink()';
    return {'error' => 1};
  }

  unless ($args->{invite_link}) {
    cluck 'No invite_link supplied in editChatInviteLink()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{invite_link} = $args->{invite_link};
  $send_args->{expire_date} = $args->{expire_date} if exists $args->{expire_date};
  $send_args->{member_limit} = $args->{member_limit} if exists $args->{member_limit};

  my $url = "https://api.telegram.org/bot${token}/editChatInviteLink";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::ChatInviteLink->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
}

sub revokeChatInviteLink {
  my $self = shift;
  my $args = shift || {};
  my $send_args = {};

  my $token = $self->token || croak 'No token supplied to revokeChatInviteLink()?';

  unless ($args->{chat_id}) {
    cluck 'No chat_id supplied in revokeChatInviteLink()';
    return {'error' => 1};
  }

  unless ($args->{invite_link}) {
    cluck 'No invite_link supplied in revokeChatInviteLink()';
    return {'error' => 1};
  }

  $send_args->{chat_id} = $args->{chat_id};
  $send_args->{invite_link} = $args->{invite_link};

  my $url = "https://api.telegram.org/bot${token}/revokeChatInviteLink";
  my $api_response = $self->_post_request($url);

  if ($api_response) {
    return Teapot::Bot::Object::ChatInviteLink->create_from_hash($api_response, $self);
  }
  else {
    return {'error' => 1};
  }
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
      my $res = eval { $tx->res->json; };

      # it looks like we can catch an error here if timeout or something bad occurs,
      # try not to die in this case or we risk to stuck with $http_active=1 forever
      if ((defined $res) && $res ne '') {
        my $items = $res->{result};
        foreach my $item (@{$items}) {
          $last_update_id = $item->{update_id};
          $self->_process_message($item);
        }
      } else {
        cluck "Unable to get update from API: $EVAL_ERROR";
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
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{message}, $self)                         if $item->{message};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{edited_message}, $self)                  if $item->{edited_message};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{channel_post}, $self)                    if $item->{channel_post};
    $update = Teapot::Bot::Object::Message->create_from_hash($item->{edited_channel_post}, $self)             if $item->{edited_channel_post};
    # Not yet implemented, we have no InlineQuery object yet
    #$update = Teapot::Bot::Object::InlineQuery->create_from_hash($tem->{inline_query}, $self)                if $item->{inline_query};
    # Not yet implemented, we have no ChosenInlineResult object yet
    #$update = Teapot::Bot::Object::ChosenInlineResult->create_from_hash($tem->{chosen_inline_result}, $self) if $item->{chosen_inline_result};
    # Not yet implemented, we have no callback_query object yet, because we do not use this mechanism, s API should not gi us that shit
    #$update = Teapot::Bot::Object::CallbackQuery->create_from_hash($tem->{callback_query}, $self)            if $item->{callback_query};
    # Not yet implemented, we have no ShippingQuery object yet
    #$update = Teapot::Bot::Object::ShippingQuery->create_from_hash($tem->{shipping_query}, $self)            if $item->{shipping_query};
    # Not yet implemented, we have no PreCheckoutQuery object yet
    #$update = Teapot::Bot::Object::PreCheckoutQuery->create_from_hash($tem->{pre_checkout_query}, $self)     if $item->{pre_checkout_query};
    $update = Teapot::Bot::Object::Poll->create_from_hash($item->{poll}, $self)                               if $item->{poll};
    $update = Teapot::Bot::Object::PollAnswer->create_from_hash($item->{poll_answer}, $self)                  if $item->{poll_answer};
    $update = Teapot::Bot::Object::ChatMemberUpdated->create_from_hash($item->{my_chat_member}, $self)        if $item->{my_chat_member};
    $update = Teapot::Bot::Object::ChatMemberUpdated->create_from_hash($item->{chat_member}, $self)           if $item->{chat_member};

    # if we got to this point without creating a response, it must be a type we
    # don't handle yet
    if (! $update) {
      cluck 'Do not know how to handle this update: ' . Dumper($item);
      return;
    }

    foreach my $listener (@{ $self->listeners }) {
      # call the listener code, supplying ourself and the update
      my $evalRet = eval {
        $listener->($self, $update);
        return 1;
      };

      unless ($evalRet) {
        cluck "An error occured during update processing: $EVAL_ERROR";
        return;
      }
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
    cluck 'Failed to post: ' . $res->message;
    return 0; # to handle this as false in upper layers
  }
  else {
    # This must be something fatal for sure, because either is_success or is_error must be set by Mojo
    confess 'Not sure what went wrong';
  }
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Brain - A base class to make your very own Telegram bot

=head1 VERSION

version 0.022

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

=head2 kickChatMember

This is the wrapper around the C<kickChatMember> API method. See
L<https://core.telegram.org/bots/api#kickchatmember>.

Takes chat_id, and user_id as arguments. And optionally until_date and
revoke_messages.

Returns nothing, it's send-only method (Telegram API returns true on success)

=head2 unbanChatMember

This is the wrapper around the C<unbanChatMember> API method. See
L<https://core.telegram.org/bots/api#unbanchatmember>.

Takes chat_id, and user_id as arguments. And optionally only_if_banned.

Returns nothing, it's send-only method (Telegram API returns true on success)

=head2 getChat

This is the wrapper around the C<getChat> API method. See
L<https://core.telegram.org/bots/api#getchat>.

Takes chat_id as argument.

Returns the L<Teapot::Bot::Object::Chat> that represents properties of Chat.

On error returns hash reference with error set to 1

=head2 leaveChat

This is the wrapper around the C<leaveChat> API method. See
L<https://core.telegram.org/bots/api#leavechat>.

Takes chat_id as argument.

Returns nothing, it's send-only method (Telegram API returns true on success)

=head2 sendMessage

See L<https://core.telegram.org/bots/api#sendmessage>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 forwardMessage

See L<https://core.telegram.org/bots/api#forwardmessage>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 deleteMessage

See L<https://core.telegram.org/bots/api#deletemessage>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 sendPhoto

See L<https://core.telegram.org/bots/api#sendphoto>.

Returns a L<Teapot::Bot::Object::Message> object.

On error returns hash reference with error set to 1

=head2 sendChatAction
See L<https://core.telegram.org/bots/api#sendchataction>.

Returns nothing, it's send-only method (Telegram API returns true on success)

=head2 exportChatInviteLink

See L<https://core.telegram.org/bots/api#exportchatinvitelink>

Takes chat_id as argument.

Returns a raw api answer.

On error returns hash reference with error set to 1

=head2 createChatInviteLink

See L<https://core.telegram.org/bots/api#createchatinvitelink>

Takes chat_id as argument. And optionally expire_date and member_limit.

Returns a L<Teapot::Bot::Object::ChatInviteLink> object.

On error returns hash reference with error set to 1

=head2 editChatInviteLink

See L<https://core.telegram.org/bots/api#editchatinvitelink>

Takes chat_id and invite_link as arguments. And optionally expire_date
and member_limit.

Returns a L<Teapot::Bot::Object::ChatInviteLink> object.

On error returns hash reference with error set to 1

=head2 revokeChatInviteLink

See L<https://core.telegram.org/bots/api#revokechatinvitelink>

Takes chat_id and invite_link as arguments.

Returns a L<Teapot::Bot::Object::ChatInviteLink> object.

On error returns hash reference with error set to 1

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

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
