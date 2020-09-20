package telegrambot;

use 5.018;
use strict;
use warnings "all";
use vars qw/$VERSION/;
use utf8;
use Data::Dumper;
use open qw(:std :utf8);
use File::Path qw( mkpath );
use Hailo;
use Encode;
use Mojo::Base 'Telegram::Bot::Brain';

use conf;
use botlib;

use Exporter qw(import);
our @EXPORT = qw(run_telegrambot);

$VERSION = "1.0";

my $c = loadConf();
my $hailo;
my $myid;
# guess it later
my $can_talk = 0;

has token => $c->{telegrambot}->{token};

sub __cron {
	my $self = shift;
# noop
	return;
}

sub __on_msg {
	my ($self, $msg) = @_;
	my $chatid;
	$can_talk = 0;

	unless ($myid) {
		my $myObj = Telegram::Bot::Brain::getMe($self);
		$myid = $myObj->id;
	}

	if ($msg->{'chat'}->can('id')) {
		$chatid = $msg->{'chat'}->id;
		my $group_talk = 0;

		my $chatname = 'Noname chat';
		$chatname = $msg->{'chat'}->username if ($msg->{'chat'}->can('username'));

		# because of bot api restriction there is no events about changing permissions in chat sent to bot
		# so before sending any answer, we should check if we can do so

		# N.B. there is situation when we do not recieve any messages from chat: if we are in exception list, even if it allows any kind of events for bot

		# If we are just member of chat, it looks like we obey general chat restrictions, so we need only to query getChat in this case
		# If we admin, we can get|send messages even if group by itself disallows it.

		# works only for public chats, so id shoud be < 0.

		if ($chatid < 0) {
			my $chatobj = getChat ($self, $chatid);
			# actually evaluates to 1 for true and to 0 for false
			$group_talk = int ($chatobj->{permissions}->{can_send_messages});
		}

		my $chatObj = getChatMember ($self, $chatid, $myid);

		if ($chatObj->{'status'} eq 'administrator') {
			logger "can talk in $chatname";
			$can_talk = 1;
		} else {
			logger "can talk in $chatname" if ($group_talk);
			logger "can not talk in $chatname" unless ($group_talk);
			$can_talk = $group_talk;
		}
	} else {
		logger "mute in $chatid";
	}

	my $phrase;

	if (($msg->{'new_chat_members'}) && $can_talk) {
		# we have newcommers here
		my $newcommer;

		if ($msg->{'new_chat_members'}->can('first_name')) {
			$newcommer .= $msg->{'new_chat_members'}->first_name;

			if ($msg->{'new_chat_members'}->can('last_name')) {
				$newcommer .= ' ' . $msg->{'new_chat_members'}->last_name;
			}
		} elsif ($msg->{'new_chat_members'}->can('last_name')) {
			$newcommer .= $msg->{'new_chat_members'}->last_name;
		} elsif ($msg->{'new_chat_members'}->can('username')) {
			$newcommer .= $msg->{'new_chat_members'}->username;
		}

		if ($newcommer) {
			$msg->reply("Дратути, $newcommer. Представьтес, пожалуйста, и расскажите, что вас сюда привело.");
			logger "newcommer $newcommer in $chatid";
		} else {
			logger "newcommer in $chatid";
			$msg->reply("Дратути. Представьтес, пожалуйста, и расскажите, что вас сюда привело.");
		}

		return;
	}

# lazy init chat-bot brains
	unless (defined($hailo->{$chatid})) {
		$hailo->{$chatid} = Hailo->new(
# we'll got file like this: data/telegrambot-brains/-1001332512695.brain.sqlite
			brain => sprintf("%s/%s.brain.sqlite", $c->{telegrambot}->{braindir}, $chatid),
			order => 3
		);
	}

# is this a 1-on-1 ?
	if ($msg->chat->type eq 'private') {
		return unless(defined($msg->text));
		my $text = $msg->text;
		my $csign = quotemeta($c->{telegrambot}->{csign});
		my $reply;

		if (substr($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr($text, 1) eq "ping") {
				$reply = "Pong.";
			} elsif (substr($text, 1) eq "пинг") {
				$reply = "Понг.";
			} elsif (substr($text, 1, 1) eq 'w' || substr($text, 1, 1) eq 'п') {
				my $city = substr($text, 2);
				$reply = weather($city);
			} else {
				$reply = "Чего?";
			}
		} else {
			$reply = $hailo->{$msg->chat->id}->learn_reply($text);
		}

		if (defined($reply) && $reply ne '') {
			$msg->reply($reply);
			logger ("private chat reply: $reply");
		} else {
# if we have no answer, say something default in private chat
			$msg->reply("Давайте ещё пообщаемся, а то я ещё не научилась от вас плохому.");
		}
# group chat
	} elsif (($msg->chat->type eq 'supergroup') or ($msg->chat->type eq 'group')) {
		my $reply;

		unless(defined($msg->text)) {
			logger "No text in message";
			logger Dumper($msg);
			return;
		}

		my $text = $msg->text;
# sometimes shit happens?
		return unless(defined($text));

		my $qname = quotemeta($c->{telegrambot}->{name});
		my $qtname = quotemeta($c->{telegrambot}->{tname});
		my $csign = quotemeta($c->{telegrambot}->{csign});

# simple commands
		if (substr($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr($text, 1) eq "help") {
				return unless ($can_talk);
				my $send_args;
				$send_args->{text} = '```
!help | !помощь     - список команд
!w город | !п город - погода в указанном городе
!ping | !пинг       - попинговать бота
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
';
				$send_args->{parse_mode} = 'Markdown';
				$send_args->{chat_id} = $chatid;
				Telegram::Bot::Brain::sendMessage($self, $send_args);
				return;
			} elsif (substr($text, 1) eq "ping") {
				$reply = "Pong.";
			} elsif (substr($text, 1) eq "пинг") {
				$reply = "Понг.";
			} elsif (substr($text, 1) eq "pong") {
				$reply = "Wat?";
			} elsif (substr($text, 1) eq "понг") {
				$reply = "Шта?";
			} elsif (substr($text, 1, 2) eq 'w ' || substr($text, 1, 2) eq 'п ') {
				my $city = substr($text, 3);
				$reply = weather($city);
			}
		} elsif (
				($text eq $qname) or
				($text eq sprintf("%s", $qtname)) or
				($text eq sprintf("@%s_bot", $qname)) or # :(
				($text eq sprintf("%s ", $qtname))
			) {
				$reply = "Чего?";
		} else {
# phrase directed to bot
			if ((lc($text) =~ /^${qname}[\,|\:]? (.+)/) or (lc($text) =~ /^${qtname}[\,|\:]? (.+)/)){
				$phrase = $1;
				$reply = $hailo->{$msg->chat->id}->learn_reply($phrase);
# bot mention by name
			} elsif ((lc($text) =~ /.+ ${qname}[\,|\!|\?|\.| ]/) or (lc($text) =~ / $qname$/)) {
				$phrase = $text;
				$reply = $hailo->{$msg->chat->id}->reply($phrase);
# bot mention by telegram name
			} elsif ((lc($text) =~ /.+ ${qtname}[\,|\!|\?|\.| ]/) or (lc($text) =~ / $qtname$/)) {
				$phrase = $text;
				$reply = $hailo->{$msg->chat->id}->reply($phrase);
# just message in chat
			} else {
				$hailo->{$msg->chat->id}->learn($text);
			}
		}

		if (defined($reply) && $reply ne '' && $can_talk) {
			# work a bit more on input phrase
			$phrase = trim($phrase);

			while ($phrase =~ /[\.|\,|\?|\!]$/) {
				chop $phrase;
			}

			$phrase = lc($phrase);

			if (lc($reply) eq $phrase) {
				$reply = randomCommonPhrase();
			} elsif (lc($reply) eq substr($phrase, 0, -1)) {
				# in case of trailing dot
				$reply = randomCommonPhrase();
			} elsif (substr(lc($reply), 0, -1) eq $phrase) {
				$reply = randomCommonPhrase();
			}

			logger ("reply with: $reply");
			$msg->reply($reply);
		} else {
			if ($can_talk) {
				logger ("no reply");
			} else {
				logger ("Can't talk, but reply is: $reply");
			}
		}

# should be channel, so we can't talk
	} else {
		return;
	}

	return;
}

# setup our bot
sub init {
	unless (-d $c->{telegrambot}->{braindir}) {
		mkpath ($c->{telegrambot}->{braindir}, 0, 0755);
	}

	my $self = shift;
	$self->add_listener(\&__on_msg);
	# $self->add_repeating_task(900, \&__cron);
}

sub run_telegrambot {
	while (sleep 3) {
		eval {
			telegrambot->new->think;
		}
	}
}

# complete framework with our getChat()
sub getChat {
	my $self = shift;
	my $id = shift;
	my $send_args = {};
	$send_args->{chat_id} = $id;

	my $token = $self->token;
	my $url = "https://api.telegram.org/bot${token}/getChat";
	my $api_response = $self->_post_request($url, $send_args);

	# we seek for permissions, when making call to this subroutine, but
	# framework does just omits it, when creating object from hash, so
	# pick raw json object instead

	#return Telegram::Bot::Object::User->create_from_hash($api_response, $self);
	return $api_response;
}

# complete framework with our getChatMember()
sub getChatMember {
	my $self = shift;
	my $chatid = shift;
	my $userid = shift;
	my $send_args = {};
	$send_args->{chat_id} = $chatid;
	$send_args->{user_id} = $userid;
	my $token = $self->token;
	my $url = "https://api.telegram.org/bot${token}/getChatMember";
	my $api_response = $self->_post_request($url, $send_args);

	# return Telegram::Bot::Object::User->create_from_hash($api_response, $self);
	return $api_response;
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
