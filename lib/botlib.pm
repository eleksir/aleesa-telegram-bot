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
use archeologist qw (dig);
use fisher qw (fish);
use fortune qw (fortune fortune_toggle fortune_status);
use friday qw (friday);
use karma qw (karmaSet karmaGet);
use kitty qw (kitty);
use lat qw (latAnswer);
use util qw (trim);
use weather qw (weather);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (randomCommonPhrase command highlight botsleep);

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
	my ($userid, $username, $fullname, $highlight, $visavi) = highlight $msg;

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
	} elsif ((length ($text) >= 6 && (substr ($text, 1, 6) eq 'karma ' || substr ($text, 1, 6) eq 'карма '))  ||  substr ($text, 1) eq 'karma'  ||  substr ($text, 1) eq 'карма') {
		my $mytext = '';

		if (length($text) > 6) {
			$mytext = substr $text, 7;
			chomp $mytext;
			$mytext = trim $mytext;
		} else {
			$mytext = '';
		}

		$reply = karmaGet ($chatid, $mytext);
	} elsif (substr ($text, 1) eq 'friday'  ||  substr ($text, 1) eq 'пятница') {
		$reply = friday ();
	} elsif (substr ($text, 1) eq 'fortune'  ||  substr ($text, 1) eq 'фортунка'  ||  substr ($text, 1) eq 'f'  ||  substr ($text, 1) eq 'ф') {
		$reply = sprintf "```\n%s\n```\n", trim (fortune ());
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'f 1'  ||  substr ($text, 1) eq 'fortune 1'  ||  substr ($text, 1) eq 'фортунка 1'  ||  substr ($text, 1) eq 'ф 1') {
		$reply = fortune_toggle ($chatid, 1);
	} elsif (substr ($text, 1) eq 'f 0'  ||  substr ($text, 1) eq 'fortune 0'  ||  substr ($text, 1) eq 'фортунка 0'  ||  substr ($text, 1) eq 'ф 0') {
		$reply = fortune_toggle ($chatid, 0);
	} elsif (substr ($text, 1) eq 'f ?'  ||  substr ($text, 1) eq 'fortune ?'  ||  substr ($text, 1) eq 'фортунка ?'  ||  substr ($text, 1) eq 'ф ?') {
		$reply = fortune_status ($chatid);
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
${csign}cat | ${csign}кис                 - кошечка
${csign}dig | ${csign}копать              - заняться археологией
${csign}fish | ${csign}рыба | ${csign}рыбка      - порыбачить
${csign}fishing | ${csign}рыбалка         - порыбачить
${csign}f | ${csign}ф                     - рандомная фраза из сборника цитат fortune_mod
${csign}fortune | ${csign}фортунка        - рандомная фраза из сборника цитат fortune_mod
${csign}f # | ${csign}ф #                 - где 1 - вкл, 0 - выкл фортунку с утра
${csign}fortune # | ${csign}фортунка #    - где 1 - вкл, 0 - выкл фортунку с утра
${csign}f ? | ${csign}ф ?                 - показываем ли с утра фортунку для чата
${csign}fortune ? | ${csign}фортунка ?    - показываем ли с утра фортунку для чата
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

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
