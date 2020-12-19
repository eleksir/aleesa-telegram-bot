package telegrambot;
# main bot gears are here

use 5.018;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use open qw(:std :utf8);
use Carp qw(carp);
use File::Path qw(mkpath);
use Hailo;
use Mojo::Base 'Teapot::Bot::Brain';
use conf qw(loadConf);
use botlib qw(weather trim randomCommonPhrase command highlight);
use karma qw(karmaSet);
use fortune qw(fortune fortune_toggle_list);

use vars qw/$VERSION/;
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

has token => $c->{telegrambot}->{token};

sub __cron {
	my $self = shift;

#   fortune mod
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime (time);

	if ($hour == 8 && ($min >= 0 && $min <= 14)) {
		foreach my $enabledfortunechat (fortune_toggle_list ()) {
			my $send_args;
			$send_args->{text} = sprintf "Сегодняшний день пройдёт под эгидой фразы:\n%s", fortune ();
			$send_args->{chat_id} = $enabledfortunechat;
			Teapot::Bot::Brain::sendMessage ($self, $send_args);
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
	my ($userid, $username, $fullname, $highlight, $vis_a_vi) = highlight ($msg);

	unless ($myid) {
		my $myObj = Teapot::Bot::Brain::getMe ($self);

		unless ($myObj) {
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
	} else {
		carp '[INFO] Unable to get chatid';
	}

	my $phrase = '';

	# Newcommer event, greet our new member and suggest to introduce themself.
	if ($msg->can ('new_chat_members') && defined ($msg->new_chat_members)) {
		if (defined ($username)) {
			if (defined ($fullname)) {
				carp "[DEBUG] Newcommer in $chatname ($chatid): \@$username, $fullname ($userid)" if $c->{debug};
				$phrase = "Дратути, [$fullname](tg://user?id=$userid). Представьтес, пожалуйста, и расскажите, что вас сюда привело.";
			} else {
				carp "[DEBUG] Newcommer in $chatname ($chatid): \@$username ($userid)" if $c->{debug};
				$phrase = "Дратути, [$username](tg://user?id=$userid). Представьтес, пожалуйста, и расскажите, что вас сюда привело.";
			}
		} else {
			carp "[DEBUG] Newcommer in $chatname ($chatid): $fullname ($userid)" if $c->{debug};
			$phrase = "Дратути, [$fullname](tg://user?id=$userid). Представьтес, пожалуйста, и расскажите, что вас сюда привело.";
		}

		# let's emulate real human and delay answer
		sleep (int ( rand (2) + 1));

		for (0..(4 + int (rand (3)))) {
			$msg->typing ();
			sleep(3);
			sleep 3 unless ($_);
		}

		sleep ( 3 + int ( rand (2)));

		$msg->replyMd ($phrase);
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
			carp "[INFO] Initialized brain for public chat $chatname ($chatid): $brainname";
		} else {
			carp "[INFO] Initialized for private chat $chatname ($chatid): $brainname";
		}
	}

# is this a 1-on-1 ?
	if ($msg->chat->type eq 'private') {
		# TODO: what about stickers, photos, documents, audio, video, etc... We should log em at least.
		return unless ($msg->can ('text') && defined ($msg->text));

		my $text = $msg->text;
		carp sprintf ('[DEBUG] Private chat %s say to bot: %s', $vis_a_vi, $text) if $c->{debug};
		my $csign = quotemeta ($c->{telegrambot}->{csign});
		my $reply = 'Давайте ещё пообщаемся, а то я ещё не научилась от вас плохому.';

		if (substr ($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr ($text, 1) eq 'help'  ||  substr ($text, 1) eq 'помощь') {
				$reply = << 'MYHELP';
```
!help | !помощь           - список команд
!dig | !копать            - заняться археологией
!f | !ф                   - рандомная фраза из сборника цитат fortune_mod
!fortune | !фортунка      - рандомная фраза из сборника цитат fortune_mod
!f # | !ф #               - где 1 - вкл, 0 - выкл фортунку с утра
!fortune # | !фортунка #  - где 1 - вкл, 0 - выкл фортунку с утра
!f ? | !ф ?               - показываем ли с утра фортунку для чата
!fortune ? | !фортунка ?  - показываем ли с утра фортунку для чата
!friday | !пятница        - а не пятница ли сегодня?
!lat | !лат               - сгенерировать фразу из крылатых латинских выражений
!ping | !пинг             - попинговать бота
!ver | !version | !версия - что-то про версию ПО
!w город | !п город       - погода в указанном городе
!karma | !карма фраза     - посмотреть карму фразы
фраза-- | фраза++         - убавить или добавить карму фразе
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
MYHELP
				$msg->replyMd ($reply);
				return;
			} else {
				$reply = command ($self, $msg, $text, $userid);
			}
		} else {
			my $just_message_in_chat = 0;

			if (substr ($text, -2) eq '++'  ||  substr ($text, -2) eq '--') {
				my @arr = split(/\n/, $text);

				if ($#arr < 1) {
					$reply = karmaSet ($chatid, trim (substr ($text, 0, -2)), substr ($text, -2));
				} else {
					$just_message_in_chat = 1;
				}
			}

			if ($just_message_in_chat) {
				my $str = $hailo->{$msg->chat->id}->learn_reply ($text);

				if (defined ($str) && $str ne '') {
					$reply = $str;
					$phrase = trim ($text);

					while ($phrase =~ /[\.|\,|\?|\!]$/) {
						chop $phrase;
					}

					$phrase = lc ($phrase);

					if (lc ($reply) eq $phrase) {
						$reply = randomCommonPhrase ();
					} elsif (lc ($reply) eq substr ($phrase, 0, -1)) {
						# in case of trailing dot
						$reply = randomCommonPhrase ();
					} elsif (substr (lc ($reply), 0, -1) eq $phrase) {
						$reply = randomCommonPhrase ();
					}
				}
			}
		}

		if (defined $reply) {
			$msg->typing ();
			sleep 1;
			carp sprintf ("[DEBUG] Private chat bot reply to $vis_a_vi: %s", $reply) if $c->{debug};
			$msg->reply ($reply);
		}
# group chat
	} elsif (($msg->chat->type eq 'supergroup') or ($msg->chat->type eq 'group')) {
		my $reply;

		# detect and log messages without text, noop here
		unless (defined ($msg->text)) {
			carp sprintf ('[INFO] No text in message from %s', $vis_a_vi);

			if ($msg->can ('document') && defined ($msg->document)) {
				if (defined ($msg->document->{'file_name'})) {
					my $docsize = 'unknown';
					$docsize = $msg->document->{'file_size'} if (defined ($msg->document->{'file_size'}));
					my $type = 'unknown';
					$type = $msg->document->{'mime_type'} if (defined ($msg->document->{'mime_type'}));
					carp sprintf ('[DEBUG] In public chat %s (%s) %s send document type %s named %s, size %s bytes', $chatname, $chatid, $vis_a_vi, $type, $msg->document->{'file_name'}, $docsize) if $c->{debug};
				} else {
					carp sprintf ('In public chat %s (%s) %s send unknown document', $chatname, $chatid, $vis_a_vi) if $c->{debug};
				}
			} elsif ($msg->can ('sticker') && defined ($msg->sticker)) {
				my $set_name = 'unknown';
				$set_name = $msg->sticker->set_name if ($msg->sticker->can ('set_name') && defined ($msg->sticker->set_name));
				my $emoji = 'unknown';
				$emoji = $msg->sticker->emoji if ($msg->sticker->can ('emoji') && defined ($msg->sticker->emoji));
				carp sprintf ('[DEBUG] In public chat %s (%s) %s reacted with sticker %s from pack %s', $chatname, $chatid, $vis_a_vi, $emoji, $set_name) if $c->{debug};
			} elsif ($msg->can ('photo') && defined ($msg->photo)) {
				# actually it is an array! duh, hate arrays!
				carp sprintf ('[DEBUG] In public chat %s (%s) %s send photo', $chatname, $chatid, $vis_a_vi) if $c->{debug};
			} else {
				carp Dumper ($msg) if $c->{debug};
			}

			return;
		}

		# we have text here! so potentially we can chit-chat
		my $text = $msg->text;
		carp sprintf ('[DEBUG] In public chat %s (%s) %s say: %s', $chatname, $chatid, $vis_a_vi, $text) if $c->{debug};
		my $qname = quotemeta ($c->{telegrambot}->{name});
		my $qtname = quotemeta ($c->{telegrambot}->{tname});
		my $csign = quotemeta ($c->{telegrambot}->{csign});

		# are they quote something, maybe, us?
		if (defined ($msg->reply_to_message) &&
		            defined ($msg->reply_to_message->from) &&
		                    defined ($msg->reply_to_message->from->username) &&
		                            ($msg->reply_to_message->from->username eq $myusername)) {
			carp sprintf ('[DEBUG] In public chat %s (%s) %s quote us!', $chatname, $chatid, $vis_a_vi) if $c->{debug};
			# remove our name from users reply, just in case
			my $pat1 = quotemeta ('@' . $myusername);
			my $pat2 = quotemeta ($myfullname);
			$phrase = $text;
			$phrase =~ s/$pat1//g;
			$phrase =~ s/$pat2//g;

			# figure out reply :)
			$reply = $hailo->{$msg->chat->id}->learn_reply ($phrase) if (length ($phrase) > 3);
		# simple commands
		# TODO: Log commands and answers
		} elsif (substr ($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr ($text, 1) eq 'help'  ||  substr ($text, 1) eq 'помощь') {
				$reply = << 'MYHELP';
```
!help | !помощь           - список команд
!dig | !копать            - заняться археологией
!f | !ф                   - рандомная фраза из сборника цитат fortune_mod
!fortune | !фортунка      - рандомная фраза из сборника цитат fortune_mod
!f # | !ф #               - где 1 - вкл, 0 - выкл фортунку с утра
!fortune # | !фортунка #  - где 1 - вкл, 0 - выкл фортунку с утра
!f ? | !ф ?               - показываем ли с утра фортунку для чата
!fortune ? | !фортунка ?  - показываем ли с утра фортунку для чата
!friday | !пятница        - а не пятница ли сегодня?
!lat | !лат               - сгенерировать фразу из крылатых латинских выражений
!ping | !пинг             - попинговать бота
!ver | !version | !версия - что-то про версию ПО
!w город | !п город       - погода в указанном городе
!karma | !карма фраза     - посмотреть карму фразы
фраза-- | фраза++         - убавить или добавить карму фразе
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
MYHELP
				$msg->replyMd ($reply);
				return;
			} else {
				$reply = command ($self, $msg, $text, $chatid);
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
			} elsif (substr ($text, -2) eq '++'  ||  substr ($text, -2) eq '--') {
				my @arr = split(/\n/, $text);

				if ($#arr < 1) {
					$reply = karmaSet ($chatid, trim (substr ($text, 0, -2)), substr ($text, -2));
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
			$phrase = trim ($phrase);

			while ($phrase =~ /[\.|\,|\?|\!]$/) {
				chop $phrase;
			}

			$phrase = lc ($phrase);

			if (lc ($reply) eq $phrase) {
				$reply = randomCommonPhrase ();
			} elsif (lc ($reply) eq substr ($phrase, 0, -1)) {
				# in case of trailing dot
				$reply = randomCommonPhrase ();
			} elsif (substr (lc ($reply), 0, -1) eq $phrase) {
				$reply = randomCommonPhrase ();
			}

			$msg->typing ();
			sleep (int (rand (2)));
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
	unless (-d $c->{telegrambot}->{braindir}) {
		mkpath ($c->{telegrambot}->{braindir}, 0, 0755); ## no critic (ValuesAndExpressions::ProhibitLeadingZeros)
	}

	my $self = shift;
	$self->add_listener (\&__on_msg);
	$self->add_repeating_task (900, \&__cron);
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
