package botlib;
# store here utility functions that are not protocol-specified

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (carp);
use Math::Random::Secure qw (irand);

use conf qw (loadConf);
use admin qw (@forbiddenMessageTypes getForbiddenTypes addForbiddenType delForbiddenType listForbidden fortune_toggle fortune_status plugin_toggle plugin_status pluginEnabled);
use archeologist qw (dig);
use fisher qw (fish);
use fortune qw (fortune);
use friday qw (friday);
use image qw (kitty fox oboobs obutts rabbit);
use karma qw (karmaSet karmaGet);
use lat qw (latAnswer);
use util qw (trim);
use weather qw (weather);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (randomCommonPhrase command highlight botsleep isCensored);

my $c = loadConf ();
my $csign = $c->{telegrambot}->{csign};

sub randomCommonPhrase {
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

sub command {
	my $self = shift;
	my $msg = shift;
	my $text = shift;
	my $chatid = shift;
	my $reply;
	my ($userid, $username, $fullname, $highlight, $visavi) = highlight ($msg);

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
		$reply = weather $city;
	} elsif (substr ($text, 1) eq 'cat'  ||  substr ($text, 1) eq 'кис') {
		$reply = kitty ();
		$msg->typing ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'lat'  ||  substr ($text, 1) eq 'лат') {
		$reply = latAnswer ();
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

		$reply = karmaGet ($chatid, $mytext);
	} elsif (substr ($text, 1) eq 'fox'  ||  substr ($text, 1) eq 'лис') {
		$reply = fox ();
		$msg->typing ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'rabbit'  ||  substr ($text, 1) eq 'bunny'  ||  substr ($text, 1) eq 'кролик') {
		$msg->typing ();
		$reply = rabbit ();
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
		if (pluginEnabled $chatid, 'oboobs') {
			$reply = oboobs ();
			$msg->typing ();
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
		if (pluginEnabled $chatid, 'obutts') {
			$reply = obutts ();
			$msg->typing ();
			sleep (irand (2) + 1);
			$msg->replyMd ($reply);
		}

		return;
	} elsif (substr ($text, 1) eq 'friday'  ||  substr ($text, 1) eq 'пятница') {
		$reply = friday ();
	} elsif (substr ($text, 1) eq 'fortune'  ||  substr ($text, 1) eq 'фортунка'  ||  substr ($text, 1) eq 'f'  ||  substr ($text, 1) eq 'ф') {
		$reply = sprintf "```\n%s\n```\n", trim (fortune ());
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'dig' || substr ($text, 1) eq 'копать') {
		$reply = dig $highlight;
		$msg->typing ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'fish' || substr ($text, 1) eq 'fishing' || substr ($text, 1) eq 'рыба' || substr ($text, 1) eq 'рыбка' || substr ($text, 1) eq 'рыбалка' ) {
		$reply = fish $highlight;
		$msg->typing ();
		sleep (irand (2) + 1);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'help'  ||  substr ($text, 1) eq 'помощь') {
		$reply = << "MYHELP";
```
${csign}help | ${csign}помощь             - список команд
${csign}bunny | ${csign}rabbit | ${csign}кролик  - кролик (бета-версия)
${csign}cat | ${csign}кис                 - кошечка
${csign}dig | ${csign}копать              - заняться археологией
${csign}fish | ${csign}рыба | ${csign}рыбка      - порыбачить
${csign}fishing | ${csign}рыбалка         - порыбачить
${csign}f | ${csign}ф                     - рандомная фраза из сборника цитат fortune_mod
${csign}fortune | ${csign}фортунка        - рандомная фраза из сборника цитат fortune_mod
${csign}fox | ${csign}лис                 - лисичка
${csign}friday | ${csign}пятница          - а не пятница ли сегодня?
${csign}lat | ${csign}лат                 - сгенерить фразу из крылатых латинских выражений
${csign}ping | ${csign}пинг               - попинговать бота
${csign}ver | ${csign}version | ${csign}версия   - что-то про версию ПО
${csign}w город | ${csign}п город         - погода в указанном городе
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
						foreach (@forbiddenMessageTypes) {
							if ($msgType eq $_) {
								if ($toggle == 1) {
									addForbiddenType ($chatid, $msgType);
									$reply = "Теперь сообщения с $msgType будут автоматически удаляться";
								} elsif ($toggle == 0) {
									delForbiddenType ($chatid, $msgType);
									$reply = "Теперь сообщения с $msgType будут оставаться";
								}
							}
						}
					}
				} else {
					$reply = listForbidden ($chatid);
				}
			} elsif ($cmd eq 'fortune' || $cmd eq 'фортунка') {
				if (defined $args) {
					if ($args == 1) {
						$reply = fortune_toggle ($chatid, 1);
					} elsif ($args == 0) {
						$reply = fortune_toggle ($chatid, 0);
					}
				} else {
					$reply = fortune_status ($chatid);
				}
			} elsif ($cmd eq 'oboobs') {
				if (defined $args) {
					if ($args == 1) {
						$reply = plugin_toggle ($chatid, 'oboobs', 1);
					} elsif ($args == 0) {
						$reply = plugin_toggle ($chatid, 'oboobs', 0);
					}
				} else {
					$reply = plugin_status ($chatid, 'oboobs');
				}
			} elsif ($cmd eq 'obutts') {
				if (defined $args) {
					if ($args == 1) {
						$reply = plugin_toggle ($chatid, 'obutts', 1);
					} elsif ($args == 0) {
						$reply = plugin_toggle ($chatid, 'obutts', 0);
					}
				} else {
					$reply = plugin_status ($chatid, 'obutts');
				}
			}
		}
	}

	return $reply;
}

sub highlight {
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

sub botsleep {
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

sub isCensored {
	my $msg = shift;

	my $forbidden = getForbiddenTypes ($msg->chat->id);

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
