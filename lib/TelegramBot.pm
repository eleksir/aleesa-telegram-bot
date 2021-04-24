package TelegramBot;
# main bot gears are here

use 5.018;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck carp);
use File::Path qw (make_path);
use Hailo;
use Math::Random::Secure qw (irand);
use Mojo::Base 'Teapot::Bot::Brain';
use BotLib::Admin qw (FortuneToggleList);
use BotLib qw (RandomCommonPhrase Command Highlight BotSleep IsCensored);
use BotLib::Conf qw (LoadConf);
use BotLib::Fortune qw (Fortune);
use BotLib::Karma qw (KarmaSet);
use BotLib::Util qw (trim fmatch);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (RunTelegramBot);

my $c = LoadConf ();
my $hailo;
my $myid;
my $myusername;
my $myfirst_name;
my $mylast_name;
my $myfullname;

has token => $c->{telegrambot}->{token};

sub __cron {
	my $self = shift;

	# fortune mod
	my @intro = (
		'Сегодняшний день пройдёт под эгидой фразы:',
		'Крылатая фраза на сегодня:',
		'Сегодняшняя фраза дня:',
	);

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime (time);

	if ($hour == 8 && ($min >= 0 && $min <= 14)) {
		foreach my $enabledfortunechat (fortuneToggleList ()) {
			my $send_args;
			$send_args->{text} = sprintf "%s\n```\n%s\n```\n", $intro[irand ($#intro + 1)], trim (Fortune ());
			$send_args->{chat_id} = $enabledfortunechat;
			$send_args->{parse_mode} = 'Markdown';
			$self->sendMessage ($send_args);
		}
	}

	return;
}

sub __on_msg {
	my ($self, $msg) = @_;
	# chat info
	my $chatid;
	my $chatname = 'Noname chat';
	# user sending message info
	my ($userid, $username, $fullname, $highlight, $vis_a_vi) = BotLib::Highlight ($msg);
	my $csign = $c->{telegrambot}->{csign};

	unless ($myid) {
		my $myObj = $self->getMe ();

		unless ($myObj) {
			carp '[ERROR] Unable to get chatid, API Error?';
			return;
		}

		$myid = $myObj->id;
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

		if ($msg->chat->can ('username') && defined ($msg->chat->username)) {
			$chatname = $msg->chat->username ;
		} else {
			if ($msg->chat->can ('title') && defined ($msg->chat->title)) {
				$chatname = $msg->chat->title;
			} else {
				$chatname = 'Noname chat';
			}
		}
	} else {
		carp '[INFO] Unable to get chatid';
		return;
	}

	my $phrase = '';

	# Newcommer event, greet our new member and suggest to introduce themself.
	if ($msg->can ('new_chat_members') && defined ($msg->new_chat_members)) {
		my @members;

		foreach my $member (@{$msg->new_chat_members}) {
			my $member_str = '';

			if ($member->can ('first_name') && defined ($member->first_name)) {
				$member_str .= $member->first_name;

				if ($member->can ('last_name') && defined ($member->last_name)) {
					$member_str .= ' ' . $member->last_name;
				}
			} else {
				if ($member->can ('last_name') && defined ($member->last_name)) {
					$member_str .= ' ' . $member->last_name;
				} else {
					$member_str .= '@' . $member->username;
				}
			}

			push @members, sprintf '[%s](tg://user?id=%s)', $member_str, $member->id;
		};

		if ($#members > 1) {
			my $lastone = pop @members;
			$phrase = sprintf 'Дратути, %s и %s. Представьтес, пожалуйста, и расскажите, что вас сюда привело.', join (', ', @members), $lastone;
		} else {
			$phrase = sprintf 'Дратути, %s. Представьтес, пожалуйста, и расскажите, что вас сюда привело.', $members[0];
		}

		BotSleep $msg;
		$msg->replyMd ($phrase);
		return;
	}

# lazy init chat-bot brains
	unless (defined $hailo->{$chatid}) {
		my $brainname = sprintf '%s/%s.brain.sqlite', $c->{telegrambot}->{braindir}, $chatid;

		$hailo->{$chatid} = Hailo->new (
# we'll got file like this: data/telegrambot-brains/-1001332512695.brain.sqlite
			brain => $brainname,
			order => 3
		);

		if ($chatid < 0) {
			carp "[INFO] Initialized brain for public chat $chatname ($chatid): $brainname";
		} else {
			carp "[INFO] Initialized brain for private chat $chatname ($chatid): $brainname";
		}
	}

# is this a 1-on-1 ?
	if ($msg->chat->type eq 'private') {
		unless (defined $msg->text) {
			return;
		}

		my $text = $msg->text;
		carp sprintf ('[DEBUG] Private chat %s say to bot: %s', $vis_a_vi, $text) if $c->{debug};
		my $reply = 'Давайте ещё пообщаемся, а то я ещё не научилась от вас плохому.';

		if (substr ($text, 0, 1) eq $csign) {
			$reply = Command ($self, $msg, $text, $userid);
		} else {
			my $just_message_in_chat = 0;

			# is it karma adjustment?
			if (substr ($text, -2) eq '++'  ||  substr ($text, -2) eq '--') {
				my @arr = split /\n/, $text;

				if ($#arr < 1) {
					$reply = KarmaSet ($chatid, trim (substr ($text, 0, -2)), substr ($text, -2));
				} else {
					$just_message_in_chat = 1;
				}
			}

			if ($just_message_in_chat) {
				my $str = $hailo->{$msg->chat->id}->learn_reply ($text);

				if (defined ($str) && $str ne '') {
					$reply = $str;
					$phrase = trim $text;

					while ($phrase =~ /[\.|\,|\?|\!]$/) {
						chop $phrase;
					}

					$phrase = lc $phrase;

					if (fmatch (lc ($reply), $phrase)) {
						$reply = RandomCommonPhrase ();
					}
				}
			}
		}

		if (defined $reply) {
			$msg->typing ();
			sleep 1;
			carp sprintf ('[DEBUG] Private chat bot reply to %s: %s', $vis_a_vi, $reply) if $c->{debug};
			$msg->reply ($reply);
		}
# group chat
	} elsif (($msg->chat->type eq 'supergroup') or ($msg->chat->type eq 'group')) {
		my $reply;

		if (IsCensored $msg) {
			carp sprintf '[INFO] In public chat %s (%s) message from %s was censored', $chatname, $chatid, $vis_a_vi;
			$self->deleteMessage ({chat_id => $chatid, message_id => $msg->{message_id}});
		}

		# detect and log messages without text, noop here
		unless (defined $msg->text) {
			carp sprintf ('[INFO] No text in message from %s', $vis_a_vi);
			return;
		}

		# we have text here! so potentially we can chit-chat
		my $text = $msg->text;
		carp sprintf ('[DEBUG] In public chat %s (%s) %s say: %s', $chatname, $chatid, $vis_a_vi, $text) if $c->{debug};

		# are they quote something, maybe, us?
		if (defined ($msg->reply_to_message) &&
		            defined ($msg->reply_to_message->from) &&
		                    defined ($msg->reply_to_message->from->username) &&
		                            ($msg->reply_to_message->from->username eq $myusername)) {
			carp sprintf ('[DEBUG] In public chat %s (%s) %s quote us!', $chatname, $chatid, $vis_a_vi) if $c->{debug};

			# do not answer back if someone quote our new member greet
			if ((substr ($msg->reply_to_message->text, 0, 9) eq 'Дратути, ') &&
			    (substr ($msg->reply_to_message->text, -61) eq 'Представьтес, пожалуйста, и расскажите, что вас сюда привело.')) {
				return;
			} else {
				# remove our name from users reply, just in case
				my $pat1 = quotemeta ('@' . $myusername);
				my $pat2 = quotemeta $myfullname;
				$phrase = $text;
				$phrase =~ s/$pat1//g;
				$phrase =~ s/$pat2//g;

			# figure out reply :)
				$reply = $hailo->{$msg->chat->id}->learn_reply ($phrase) if (length ($phrase) > 3);
			}
		# simple commands
		} elsif (substr ($text, 0, 1) eq $csign) {
			$reply = Command ($self, $msg, $text, $chatid);
		} elsif (
				($text eq $myusername) or
				($text eq '@' . $myusername) or
				($text eq '@' . $myusername . ' ') or
				($text eq $myfullname) or
				($text eq $myfullname . ' ')
			) {
				$reply = 'Чего?';
		} else {
			my $qname = quotemeta ('@' . $myusername);
			my $qtname = quotemeta $myfullname;

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
			# karma adjustment
			} elsif (substr ($text, -2) eq '++'  ||  substr ($text, -2) eq '--') {
				my @arr = split /\n/, $text;

				if ($#arr < 1) {
					$reply = KarmaSet ($chatid, trim (substr ($text, 0, -2)), substr ($text, -2));
				} else {
					# just message in chat
					$hailo->{$msg->chat->id}->learn ($text);
				}
			# just message in chat
			} else {
				$hailo->{$msg->chat->id}->learn ($text);
			}
		}

		if (defined ($reply) && $reply ne '') {
			# work a bit more on input phrase
			$phrase = trim $phrase;

			while ($phrase =~ /[\.|\,|\?|\!]$/) {
				chop $phrase;
			}

			$phrase = lc $phrase;

			if (fmatch (lc ($reply), $phrase)) {
				$reply = RandomCommonPhrase ();
			}

			$msg->typing ();
			sleep (irand 2);
			carp sprintf ('[DEBUG] In public chat %s (%s) bot reply to %s: %s', $chatname, $chatid, $vis_a_vi, $reply) if $c->{debug};
			$msg->reply ($reply);
		} else {
			carp sprintf ('[DEBUG] In public chat %s (%s) bot is not required to reply to %s', $chatname, $chatid, $vis_a_vi) if $c->{debug};
		}

# should be channel, so we can't talk
	} else {
		return;
	}

	return;
}

# setup our bot
sub init {
	my $self = shift;
	my $braindir = $c->{telegrambot}->{braindir};

	unless (-d $braindir) {
		make_path ($braindir, 0, 0755) or do { ## no critic (ValuesAndExpressions::ProhibitLeadingZeros)
			cluck "Unable to create $braindir: $OS_ERROR";
			exit 1;
		};
	}

	$self->add_listener (\&__on_msg);
	$self->add_repeating_task (900, \&__cron);
	return;
}

sub RunTelegramBot {
	while (sleep 3) {
		eval {                                       ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
			TelegramBot->new->think;
		}
	}

	return;
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
