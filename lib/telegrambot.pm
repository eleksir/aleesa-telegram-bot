package telegrambot;
# main bot gears are here

use 5.018;
use strict;
use warnings;
use vars qw/$VERSION/;
use utf8;
use Data::Dumper;
use open qw(:std :utf8);
use File::Path qw( mkpath );
use Hailo;
use Encode;
use Mojo::Base 'Teapot::Bot::Brain';

use conf qw(loadConf);
use botlib qw(weather logger trim randomCommonPhrase);
use telegramlib qw(visavi);
use lat qw(latAnswer);

use Exporter qw(import);
our @EXPORT_OK = qw(run_telegrambot);

$VERSION = '1.0';

my $c = loadConf();
my $hailo;
my $myid;
my $myusername;
my $myfirst_name;
my $mylast_name;
my $myfullname;
# guess it later
my $can_talk = 0;

has token => $c->{telegrambot}->{token};

# i promise, i'll make use of this sub
sub __cron {                                         ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
	my $self = shift;
# noop
	return;
}

sub __on_msg {
	my ($self, $msg) = @_;
	# chat info
	my $chatid;
	my $chatname = 'Noname chat';
	# user sending message info
	my $userid;
	my $username;
	my $fullname;
	my $vis_a_vi = 'unknown';

	$can_talk = 0;

	unless ($myid) {
		my $myObj = Teapot::Bot::Brain::getMe ($self);

		unless ($myObj) do {
			sleep 3;
			$myObj = Teapot::Bot::Brain::getMe ($self);
		}

		$myid = $myObj->id;
		# TODO: use these values instead of pre-defined in config!
		$myusername = $myObj->username;
		$myfirst_name = $myObj->first_name;
		$mylast_name = $myObj->last_name;

		if (defined ($myfirst_name) && ($myfirst_name ne '') && defined ($mylast_name) && ($mylast_name ne '')) {
			$myfullname = $myfirst_name . ' ' . $mylast_name;
		} elsif (defined ($myfirst_name) && ($myfirst_name ne '')) {
			$myfullname = $myfirst_name;
		} elsif (defined ($mylast_name) && ($mylast_name ne '')) {
			$myfullname = $mylast_name;
		} else {
			$myfullname = $myusername;
		}
	}

	if ($msg->chat->can ('id') && defined ($msg->chat->id)) {
		$chatid = $msg->chat->id;
		my $group_talk = 0;

		if ($msg->chat->can ('username') && defined ($msg->chat->username)) {
			$chatname = $msg->chat->username ;
		} else {
			if ($msg->chat->can ('title') && defined ($msg->chat->title)) {
				$chatname = $msg->chat->title;
			} else {
				$chatname = 'Noname chat';
			}
		}

		# because of bot api restriction there is no events about changing permissions
		# in chat sent to bot so before sending any answer, we should check if we can do so

		# N.B. there is situation when we do not recieve any messages from chat: if we
		# are in exception list, even if it allows any kind of events for bot

		# If we are just member of chat, it looks like we obey general chat restrictions,
		# so we need only to query getChat in this case
		# If we admin, we can get|send messages even if group by itself disallows it.

		# works only for public chats, so id shoud be < 0.
		if ($chatid < 0) {
			my $chatobj = Teapot::Bot::Brain::getChat ($self, { 'chat_id' => $chatid });

			unless ($chatobj) do {
				sleep 3;
				$chatobj = Teapot::Bot::Brain::getChat ($self, { 'chat_id' => $chatid });
			}

			# actually evaluates to 1 for true and to 0 for false
			$group_talk = int ($chatobj->{permissions}->{can_send_messages});
			my $me = Teapot::Bot::Brain::getChatMember ($self, { 'chat_id' => $chatid, 'user_id' => $myid });

			unless ($me) do {
				sleep 3;
				$me = Teapot::Bot::Brain::getChatMember ($self, { 'chat_id' => $chatid, 'user_id' => $myid });
			}

			if ($me->{'status'} eq 'administrator') {
				logger "I can talk in group chat $chatname ($chatid)";
				$can_talk = 1;
			} else {
				logger "I can talk in group chat $chatname ($chatid)" if ($group_talk);
				logger "I can not talk in group chat $chatname ($chatid)" unless ($group_talk);
				$can_talk = $group_talk;
			}
		} else {
			# private chat, so definely bot can talk
			logger "I can talk in private chat $chatname ($chatid)";
			$can_talk = 1;
		}
	} else {
		logger 'Unable to get chatid';
	}

	# according api user must have username and/or first_name and/or last_name at least one of these fields
	if ($msg->can ('from') && defined ($msg->from)) {
		$userid = $msg->from->id; # it must be filled, so do not check it
		$username = $msg->from->username if ($msg->from->can ('username') && defined($msg->from->username));

		if ($msg->from->can ('first_name') && defined ($msg->from->first_name)) {
			$fullname = $msg->from->first_name;

			if ($msg->from->can('last_name') && defined ($msg->from->last_name)) {
				$fullname .= ' ' . $msg->from->last_name;
			}
		} elsif ($msg->from->can ('last_name') && defined ($msg->from->last_name)) {
			$fullname .= $msg->from->last_name;
		}

		$vis_a_vi = visavi ($userid, $username, $fullname);
	}

	my $phrase = '';

	# Newcommer event, greet our new member and suggest to introduce themself.
	if ($msg->can ('new_chat_members') && defined ($msg->new_chat_members)) {
		my $send_args;
		$send_args->{parse_mode} = 'Markdown';
		$send_args->{chat_id} = $chatid;

		if (defined ($username)) {
			if (defined ($fullname)) {
				logger "Newcommer in $chatname ($chatid): \@$username, $fullname ($userid)";
				$send_args->{text} = "Дратути, [$fullname](tg://user?id=$userid). Представьтес, пожалуйста, и расскажите, что вас сюда привело.";
			} else {
				logger "Newcommer in $chatname ($chatid): \@$username ($userid)";
				$send_args->{text} = "Дратути, [$username](tg://user?id=$userid). Представьтес, пожалуйста, и расскажите, что вас сюда привело.";
			}
		} else {
			logger "Newcommer in $chatname ($chatid): $fullname ($userid)";
			$send_args->{text} = "Дратути, [$fullname](tg://user?id=$userid). Представьтес, пожалуйста, и расскажите, что вас сюда привело.";
		}

		# let's emulate real human and delay answer
		sleep (int ( rand (2) + 1));

		for (0..(4 + int (rand (3)))) {
			Teapot::Bot::Brain::sendChatAction ($self, $chatid);
			sleep(3);
			sleep 3 unless ($_);
		}

		sleep ( 3 + int ( rand (2)));

		Teapot::Bot::Brain::sendMessage ($self, $send_args);
		return;
	}

# lazy init chat-bot brains
	unless (defined ($hailo->{$chatid})) {
		my $brainname = sprintf ('%s/%s.brain.sqlite', $c->{telegrambot}->{braindir}, $chatid);

		$hailo->{$chatid} = Hailo->new (
# we'll got file like this: data/telegrambot-brains/-1001332512695.brain.sqlite
			brain => $brainname,
			order => 3
		);

		if ($chatid < 0) {
			logger "Initialized brain for public chat $chatname ($chatid): $brainname";
		} else {
			logger "Initialized for private chat $chatname ($chatid): $brainname";
		}
	}

# is this a 1-on-1 ?
	if ($msg->chat->type eq 'private') {
		# TODO: what about stickers, photos, documents, audio, video, etc... We should log em at least.
		return unless ($msg->can ('text') && defined ($msg->text));

		my $text = $msg->text;
		logger sprintf ('Private chat %s say to bot: %s', $vis_a_vi, $text);
		my $csign = quotemeta ($c->{telegrambot}->{csign});
		my $reply = 'Давайте ещё пообщаемся, а то я ещё не научилась от вас плохому.';

		# TODO: Process commands in separate sub, they are same for public and private chats.
		if (substr ($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr ($text, 1) eq 'ping') {
				$reply = 'Pong.';
			} elsif (substr ($text, 1) eq 'пинг') {
				$reply = 'Понг.';
			} elsif (substr ($text, 1, 2) eq 'w ' || substr ($text, 1, 2) eq 'п ') {
				my $city = substr ($text, 2);
				$reply = weather ($city);
			} elsif ((length ($text) == 4) && (substr ($text, 1, 3) eq 'lat' || substr ($text, 1, 2) eq 'лат')) {
				$reply = latAnswer();
			} else {
				$reply = 'Чего?';
			}
		} else {
			my $str = $hailo->{$msg->chat->id}->learn_reply ($text);

			if (defined ($str) && $str ne '') {
				$reply = $str;
				# TODO: move it to telegramlib.pm/botlib.pm!
				$phrase = trim ($text);

				while ($phrase =~ /[\.|\,|\?|\!]$/) {
					chop $phrase;
				}

				$phrase = lc ($phrase);

				if (lc ($reply) eq $phrase) {
					$reply = randomCommonPhrase();
				} elsif (lc ($reply) eq substr ($phrase, 0, -1)) {
					# in case of trailing dot
					$reply = randomCommonPhrase();
				} elsif (substr (lc ($reply), 0, -1) eq $phrase) {
					$reply = randomCommonPhrase();
				}
			}
		}

		Teapot::Bot::Brain::sendChatAction ($self, $chatid);
		sleep 1;
		logger sprintf ("Private chat bot reply to $vis_a_vi: %s", $reply);
		$msg->reply ($reply);
# group chat
	} elsif (($msg->chat->type eq 'supergroup') or ($msg->chat->type eq 'group')) {
		my $reply;

		# detect and log messages without text, noop here
		unless (defined ($msg->text)) {
			logger sprintf('No text in message from %s', $vis_a_vi);

			if ($msg->can ('document') && defined ($msg->document)) {
				if (defined ($msg->document->{'file_name'})) {
					my $docsize = 'unknown';
					$docsize = $msg->document->{'file_size'} if (defined ($msg->document->{'file_size'}));
					my $type = 'unknown';
					$type = $msg->document->{'mime_type'} if (defined ($msg->document->{'mime_type'}));
					logger sprintf ('In public chat %s (%s) %s send document type %s named %s, size %s bytes', $chatname, $chatid, $vis_a_vi, $type, $msg->document->{'file_name'}, $docsize);
				} else {
					logger sprintf ('In public chat %s (%s) %s send unknown document', $chatname, $chatid, $vis_a_vi);
				}
			} elsif ($msg->can ('sticker') && defined ($msg->sticker)) {
				my $set_name = 'unknown';
				$set_name = $msg->sticker->set_name if ($msg->sticker->can ('set_name') && defined ($msg->sticker->set_name));
				my $emoji = 'unknown';
				$emoji = $msg->sticker->emoji if ($msg->sticker->can ('emoji') && defined ($msg->sticker->emoji));
				logger sprintf ('In public chat %s (%s) %s reacted with sticker %s from pack %s', $chatname, $chatid, $vis_a_vi, $emoji, $set_name);
			} elsif ($msg->can ('photo') && defined ($msg->photo)) {
				# actually it is an array! duh, hate arrays!
				logger sprintf ('In public chat %s (%s) %s send photo', $chatname, $chatid, $vis_a_vi);
			} else {
				logger Dumper ($msg);
			}

			return;
		}

		# we have text here! so potentially we can chit-chat
		my $text = $msg->text;
		logger sprintf ('In public chat %s (%s) %s say: %s', $chatname, $chatid, $vis_a_vi, $text);
		my $qname = quotemeta ($c->{telegrambot}->{name});
		my $qtname = quotemeta ($c->{telegrambot}->{tname});
		my $csign = quotemeta ($c->{telegrambot}->{csign});

		# are they quote something, maybe, us?
		if (defined ($msg->reply_to_message) &&
		            defined ($msg->reply_to_message->from) &&
		                    defined ($msg->reply_to_message->from->username) &&
		                            ($msg->reply_to_message->from->username eq $myusername)) {
			logger sprintf ('In public chat %s (%s) %s quote us!', $chatname, $chatid, $vis_a_vi);
			# remove our name from users reply, just in case
			my $pat1 = quotemeta ('@' . $myusername);
			my $pat2 = quotemeta ($myfullname);
			$phrase = $text;
			$phrase =~ s/$pat1//g;
			$phrase =~ s/$pat2//g;

			# figure out reply :)
			$reply = $hailo->{$msg->chat->id}->learn_reply ($phrase);
		# simple commands
		# TODO: Process commands in separate sub, they are same for public and private chats.
		# TODO: Log commands and answers
		} elsif (substr ($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr ($text, 1) eq 'help') {
				unless ($can_talk) {
					return ;
				}

				my $send_args;
				$send_args->{text} = << 'MYHELP';
```
!help | !помощь     - список команд
!w город | !п город - погода в указанном городе
!ping | !пинг       - попинговать бота
!lat | !лат         - сгенерировать фразу из крылатых латинских выражений
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
MYHELP
				$send_args->{parse_mode} = 'Markdown';
				$send_args->{chat_id} = $chatid;
				Teapot::Bot::Brain::sendMessage ($self, $send_args);
				return;
			} elsif (substr ($text, 1) eq 'ping') {
				$reply = 'Pong.';
			} elsif (substr ($text, 1) eq 'пинг') {
				$reply = 'Понг.';
			} elsif (substr ($text, 1) eq 'pong') {
				$reply = 'Wat?';
			} elsif (substr ($text, 1) eq 'понг') {
				$reply = 'Шта?';
			} elsif (substr ($text, 1, 2) eq 'w ' || substr ($text, 1, 2) eq 'п ') {
				my $city = substr ($text, 3);
				$reply = weather ($city);
			} elsif (length ($text) == 4 && (substr ($text, 1, 3) eq 'lat' || substr ($text, 1, 3) eq 'лат')) {
				$reply = latAnswer();
			}
		} elsif (
				($text eq $qname) or
				($text eq sprintf ('%s', $qtname)) or
				($text eq sprintf ("@%s_bot", $qname)) or # :(
				($text eq sprintf ('%s ', $qtname))
			) {
				$reply = 'Чего?';
		} else {
			# phrase directed to bot
			if ((lc ($text) =~ /^${qname}[\,|\:]? (.+)/) or (lc ($text) =~ /^${qtname}[\,|\:]? (.+)/)){
				$phrase = $1;
				$reply = $hailo->{$msg->chat->id}->learn_reply ($phrase);
			# bot mention by name
			} elsif ((lc ($text) =~ /.+ ${qname}[\,|\!|\?|\.| ]/) or (lc ($text) =~ / $qname$/)) {
				$phrase = $text;
				$reply = $hailo->{$msg->chat->id}->reply($phrase);
			# bot mention by telegram name
			} elsif ((lc ($text) =~ /.+ ${qtname}[\,|\!|\?|\.| ]/) or (lc ($text) =~ / $qtname$/)) {
				$phrase = $text;
				$reply = $hailo->{$msg->chat->id}->reply ($phrase);
			# just message in chat
			} else {
				$hailo->{$msg->chat->id}->learn ($text);
			}
		}

		if (defined ($reply) && $reply ne '' && $can_talk) {
			# work a bit more on input phrase
			$phrase = trim ($phrase);

			while ($phrase =~ /[\.|\,|\?|\!]$/) {
				chop $phrase;
			}

			$phrase = lc ($phrase);

			if (lc ($reply) eq $phrase) {
				$reply = randomCommonPhrase();
			} elsif (lc ($reply) eq substr ($phrase, 0, -1)) {
				# in case of trailing dot
				$reply = randomCommonPhrase();
			} elsif (substr(lc ($reply), 0, -1) eq $phrase) {
				$reply = randomCommonPhrase();
			}

			Teapot::Bot::Brain::sendChatAction ($self, $chatid);
			sleep (int (rand (2)));
			logger sprintf ('In public chat %s (%s) bot reply to %s: %s', $chatname, $chatid, $vis_a_vi, $reply);
			$msg->reply ($reply);
		} else {
			if ($can_talk) {
				logger sprintf ('In public chat %s (%s) bot is not required to reply to %s', $chatname, $chatid, $vis_a_vi);
			} else {
				logger sprintf ('In public chat %s (%s) bot can\'t talk, but reply to %s is: %s', $chatname, $chatid, $vis_a_vi, $reply);
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
		mkpath ($c->{telegrambot}->{braindir}, 0, 0755); ## no critic (ValuesAndExpressions::ProhibitLeadingZeros)
	}

	my $self = shift;
	$self->add_listener (\&__on_msg);
	# $self->add_repeating_task(900, \&__cron);
	return;
}

sub run_telegrambot {
	while (sleep 3) {
		eval {                                       ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
			telegrambot->new->think;
		}
	}

	return;
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
