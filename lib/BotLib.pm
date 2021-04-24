package BotLib;
# store here utility functions that are not protocol-specified

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (carp);
use Math::Random::Secure qw (irand);

use BotLib::Conf qw (LoadConf);
use BotLib::Admin qw (@ForbiddenMessageTypes GetForbiddenTypes AddForbiddenType
                      DelForbiddenType ListForbidden FortuneToggle FortuneStatus
                      PluginToggle PluginStatus PluginEnabled);
use BotLib::Archeologist qw (Dig);
use BotLib::Buni qw (Buni);
use BotLib::Drink qw (Drink);
use BotLib::Fisher qw (Fish);
use BotLib::Fortune qw (Fortune);
use BotLib::Friday qw (Friday);
use BotLib::Image qw (Kitty Fox Oboobs Obutts Rabbit Owl);
use BotLib::Karma qw (KarmaSet KarmaGet);
use BotLib::Lat qw (Lat);
use BotLib::Monkeyuser qw (Monkeyuser);
use BotLib::Util qw (trim);
use BotLib::Weather qw (Weather);
use BotLib::Xkcd qw (Xkcd);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (RandomCommonPhrase Command Highlight BotSleep IsCensored);

my $c = LoadConf ();
my $csign = $c->{telegrambot}->{csign};

sub RandomCommonPhrase {
	my @myphrase = (
		'Так, блядь...',
		'*Закатывает рукава* И ради этого ты меня позвал?',
		'Ну чего ты начинаешь, нормально же общались',
		'Повтори свой вопрос, не поняла',
		'Выйди и зайди нормально',
		'Я подумаю',
		'Даже не знаю что на это ответить',
		'Ты упал такие вопросы девочке задавать?',
		'Можно и так, но не уверена',
		'А как ты думаешь?',
		'А ви, таки, почему интересуетесь?',
	);

	return $myphrase[irand ($#myphrase + 1)];
}

sub Command {
	my $self = shift;
	my $msg = shift;
	my $text = shift;
	my $chatid = shift;
	my $reply;
	my ($userid, $username, $fullname, $highlight, $visavi) = Highlight ($msg);

	if (substr ($text, 1) eq 'ping') {
		$reply = 'Pong.';
	} elsif (substr ($text, 1) eq 'пинг') {
		$reply = 'Понг.';
	} elsif (substr ($text, 1) eq 'pong') {
		$reply = 'Wat?';
	} elsif (substr ($text, 1) eq 'понг') {
		$reply = 'Шта?';
	} elsif (substr ($text, 1) eq 'ver' || substr ($text, 1) eq 'version' || substr ($text, 1) eq 'версия') {
		$reply = 'Версия:  Нуль.Чего-то_там.Чего-то_там';
	} elsif (length ($text) >= 2 && (substr ($text, 1, 2) eq 'w ' || substr ($text, 1, 2) eq 'п ')) {
		my $city = substr $text, 3;
		$reply = Weather $city;
	} elsif (substr ($text, 1) eq 'buni') {
		$msg->typing ();
		$reply = Buni ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'monkeyuser') {
		$msg->typing ();
		$reply = Monkeyuser ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'cat'  ||  substr ($text, 1) eq 'кис') {
		$msg->typing ();
		$reply = Kitty ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'lat'  ||  substr ($text, 1) eq 'лат') {
		$reply = Lat ();
	} elsif (
		(length ($text) >= 6 && (substr ($text, 1, 6) eq 'karma ' || substr ($text, 1, 6) eq 'карма '))  ||
		substr ($text, 1) eq 'karma'  ||  substr ($text, 1) eq 'карма'
	) {
		my $mytext = '';

		if (length($text) > 6) {
			$mytext = substr $text, 7;
			chomp $mytext;
			$mytext = trim $mytext;
		} else {
			$mytext = '';
		}

		$reply = KarmaGet ($chatid, $mytext);
	} elsif (substr ($text, 1) eq 'xkcd') {
		$msg->typing ();
		$reply = Xkcd ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'fox'  ||  substr ($text, 1) eq 'лис') {
		$msg->typing ();
		$reply = Fox ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'rabbit'  ||  substr ($text, 1) eq 'bunny'  ||  substr ($text, 1) eq 'кролик') {
		$msg->typing ();
		$reply = Rabbit ();
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'owl'  ||  substr ($text, 1) eq 'сова') {
		$msg->typing ();
		$reply = Owl ();
		$msg->replyMd ($reply);
		return;
	} elsif (
		substr ($text, 1) eq 'tits'  ||
		substr ($text, 1) eq 'boobs'  ||
		substr ($text, 1) eq 'tities'  ||
		substr ($text, 1) eq 'boobies'  ||
		substr ($text, 1) eq 'сиси'  ||
		substr ($text, 1) eq 'сисечки'
	) {
		if (PluginEnabled $chatid, 'oboobs') {
			$msg->typing ();
			$reply = Oboobs ();
			sleep (irand (2) + 1);
			$msg->replyMd ($reply);
		}

		return;
	} elsif (
		substr ($text, 1) eq 'butt'  ||
		substr ($text, 1) eq 'booty'  ||
		substr ($text, 1) eq 'ass'  ||
		substr ($text, 1) eq 'попа'  ||
		substr ($text, 1) eq 'попка'
	) {
		if (PluginEnabled $chatid, 'obutts') {
			$msg->typing ();
			$reply = Obutts ();
			sleep (irand (2) + 1);
			$msg->replyMd ($reply);
		}

		return;
	} elsif (substr ($text, 1) eq 'friday'  ||  substr ($text, 1) eq 'пятница') {
		$reply = Friday ();
	} elsif (substr ($text, 1) eq 'fortune'  ||  substr ($text, 1) eq 'фортунка'  ||  substr ($text, 1) eq 'f'  ||  substr ($text, 1) eq 'ф') {
		$reply = sprintf "```\n%s\n```\n", trim (Fortune ());
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'drink' || substr ($text, 1) eq 'праздник') {
		$msg->typing ();
		$reply = Drink ();
		sleep (irand (2) + 1);
	} elsif (substr ($text, 1) eq 'dig' || substr ($text, 1) eq 'копать') {
		$msg->typing ();
		$reply = Dig $highlight;
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'fish' || substr ($text, 1) eq 'fishing' || substr ($text, 1) eq 'рыба' || substr ($text, 1) eq 'рыбка' || substr ($text, 1) eq 'рыбалка' ) {
		$msg->typing ();
		$reply = Fish $highlight;
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'help'  ||  substr ($text, 1) eq 'помощь') {
		$reply = << "MYHELP";
```
${csign}help | ${csign}помощь             - список команд
${csign}buni                       - рандомный стрип hapi buni
${csign}bunny | ${csign}rabbit | ${csign}кролик  - кролик
${csign}cat | ${csign}кис                 - кошечка
${csign}dig | ${csign}копать              - заняться археологией
${csign}drink | ${csign}праздник          - какой сегодня праздник?
${csign}fish | ${csign}рыба | ${csign}рыбка      - порыбачить
${csign}fishing | ${csign}рыбалка         - порыбачить
${csign}f | ${csign}ф                     - рандомная фраза из сборника цитат fortune_mod
${csign}fortune | ${csign}фортунка        - рандомная фраза из сборника цитат fortune_mod
${csign}fox | ${csign}лис                 - лисичка
${csign}friday | ${csign}пятница          - а не пятница ли сегодня?
${csign}lat | ${csign}лат                 - сгенерить фразу из крылатых латинских выражений
${csign}monkeyuser                 - рандомный стрип MonkeyUser
${csign}owl | ${csign}сова                - сова
${csign}ping | ${csign}пинг               - попинговать бота
${csign}ver | ${csign}version | ${csign}версия   - что-то про версию ПО
${csign}w город | ${csign}п город         - погода в указанном городе
${csign}xkcd                       - рандомный стрип с сайта xkcd.ru
${csign}karma фраза | ${csign}карма фраза - посмотреть карму фразы
фраза-- | фраза++           - убавить или добавить карму фразе
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
MYHELP
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'admin'  ||  substr ($text, 1) eq 'админ') {
		my $member = $self->getChatMember ({ 'chat_id' => $msg->chat->id, 'user_id' => $msg->from->id });

		# this msg should be shown only if admins of chat request it
		if (($member->status eq 'administrator') || ($member->status eq 'creator')) {
			$reply = << "MYADMIN";
```
${csign}admin censor type # - где 1 - вкл, 0 - выкл цензуры для означенного типа сообщений
${csign}админ ценз тип #    - где 1 - вкл, 0 - выкл цензуры для означенного типа сообщений
${csign}admin censor        - показать список состояния типов сообщений
${csign}админ ценз          - показать список состояния типов сообщений
${csign}admin fortune #     - где 1 - вкл, 0 - выкл фортунку с утра
${csign}admin фортунка #    - где 1 - вкл, 0 - выкл фортунку с утра
${csign}admin fortune       - показываем ли с утра фортунку для чата
${csign}admin фортунка      - показываем ли с утра фортунку для чата
${csign}admin oboobs #      - где 1 - вкл, 0 - выкл плагина oboobs
${csign}admin oboobs        - показываем ли сисечки по просьбе участников чата (команды ${csign}tits, ${csign}tities, ${csign}boobs, ${csign}boobies, ${csign}сиси, ${csign}сисечки)
${csign}admin obutts #      - где 1 - вкл, 0 - выкл плагина obutts
${csign}admin obutts        - показываем ли попки по просьбе участников чата (команды ${csign}ass, ${csign}butt, ${csign}booty, ${csign}попа, ${csign}попка)
```
Типы сообщений:
audio voice photo video animation sticker dice game poll document
MYADMIN

			$msg->replyMd ($reply);
		}

		return;
	} elsif ((substr ($text, 1, 5) eq 'admin'  ||  substr ($text, 1, 5) eq 'админ') && (length ($text) >= 8)) {
		my $member = $self->getChatMember ({ 'chat_id' => $msg->chat->id, 'user_id' => $msg->from->id });

		# this msg should be shown only if admins of chat request it
		if (($member->status eq 'administrator') || ($member->status eq 'creator')) {
			my $command = trim (substr $text, 7);
			my ($cmd, $args) = split /\s+/, $command, 2;

			if ($cmd eq '') {
				return;
			} elsif ($cmd eq 'censor' || $cmd eq 'ценз') {
				if (defined ($args) && ($args ne '')) {
					my ($msgType, $toggle) = split /\s/, $args, 2;

					if (defined $toggle) {
						foreach (@ForbiddenMessageTypes) {
							if ($msgType eq $_) {
								if ($toggle == 1) {
									AddForbiddenType ($chatid, $msgType);
									$reply = "Теперь сообщения с $msgType будут автоматически удаляться";
								} elsif ($toggle == 0) {
									DelForbiddenType ($chatid, $msgType);
									$reply = "Теперь сообщения с $msgType будут оставаться";
								}
							}
						}
					}
				} else {
					$reply = ListForbidden ($chatid);
				}
			} elsif ($cmd eq 'fortune' || $cmd eq 'фортунка') {
				if (defined $args) {
					if ($args == 1) {
						$reply = FortuneToggle ($chatid, 1);
					} elsif ($args == 0) {
						$reply = FortuneToggle ($chatid, 0);
					}
				} else {
					$reply = FortuneStatus ($chatid);
				}
			} elsif ($cmd eq 'oboobs') {
				if (defined $args) {
					if ($args == 1) {
						$reply = PluginToggle ($chatid, 'oboobs', 1);
					} elsif ($args == 0) {
						$reply = PluginToggle ($chatid, 'oboobs', 0);
					}
				} else {
					$reply = PluginStatus ($chatid, 'oboobs');
				}
			} elsif ($cmd eq 'obutts') {
				if (defined $args) {
					if ($args == 1) {
						$reply = PluginToggle ($chatid, 'obutts', 1);
					} elsif ($args == 0) {
						$reply = PluginToggle ($chatid, 'obutts', 0);
					}
				} else {
					$reply = PluginStatus ($chatid, 'obutts');
				}
			}
		}
	}

	return $reply;
}

sub Highlight {
	my $msg = shift;

	my $fullname;
	my $highlight;
	my $username;
	my $visavi = '';
	my $userid = $msg->from->id;

	if ($msg->from->can ('username') && defined $msg->from->username ) {
		$username = $msg->from->username;
	}

	if ($msg->from->can ('first_name') && defined $msg->from->first_name) {
		$fullname = $msg->from->first_name;

		if ($msg->from->can ('last_name') && defined $msg->from->last_name) {
			$fullname .= ' ' . $msg->from->last_name;
		}
	} elsif ($msg->from->can ('last_name') && defined $msg->from->last_name) {
		$fullname .= $msg->from->last_name;
	}

	if (defined $username) {
		$visavi .= '@' . $username;

		if (defined $fullname) {
			$highlight = "[$fullname](tg://user?id=$userid)";
			$visavi .= ', ' . $fullname;
		} else {
			$highlight = "[$username](tg://user?id=$userid)";
		}
	} else {
		$highlight = "[$fullname](tg://user?id=$userid)";
		$visavi .= $fullname;
	}

	$visavi .= " ($userid)";

	return ($userid, $username, $fullname, $highlight, $visavi);
}

sub BotSleep {
	# TODO: Parametrise this with fuzzy sleep time in seconds
	my $msg = shift;
	# let's emulate real human and delay answer
	sleep (irand (2) + 1);

	for (0..(4 + irand (3))) {
		$msg->typing ();
		sleep 3;
		sleep 3 unless ($_);
	}

	sleep ( 3 + irand (2));
	return;
}

sub IsCensored {
	my $msg = shift;

	my $forbidden = GetForbiddenTypes ($msg->chat->id);

	# voice messages are special
	if (defined ($msg->voice) && defined ($msg->voice->duration) && ($msg->voice->duration > 0)) {
		if ($forbidden->{'voice'}) {
			return 1;
		}
	}

	foreach (keys %{$forbidden}) {
		if ($forbidden->{$_} && (defined $msg->{$_})) {
			return 1;
		}
	}

	return 0;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
