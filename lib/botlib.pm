package botlib;
# store here utility functions that are not protocol-specified

use 5.018;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use English qw( -no_match_vars );
use Carp qw(carp);
use HTTP::Tiny;
use URI::URL;
use JSON::XS qw(decode_json encode_json);
use Digest::MD5 qw(md5_base64);
use DB_File;
use conf qw(loadConf);
use lat qw(latAnswer);
use karma qw(karmaSet karmaGet);
use friday qw(friday);
use fortune qw(fortune fortune_toggle fortune_status);
use archeologist qw (dig);

use vars qw/$VERSION/;
use Exporter qw(import);
our @EXPORT_OK = qw(weather trim randomCommonPhrase command highlight);
$VERSION = '1.0';

my $c = loadConf();

sub __urlencode {
	my $str = shift;
	my $urlobj = url $str;
	$str = $urlobj->as_string;
	$urlobj = undef; undef $urlobj;
	return $str;
}

sub trim {
	my $str = shift;

	return $str if ($str eq '');

	while (substr ($str, 0, 1) =~ /^\s$/xms) {
		$str = substr ($str, 1);
	}

	while (substr ($str, -1, 1) =~ /^\s$/xms) {
		chop ($str);
	}

	return $str;
}


sub weather {
	my $city = shift;
	$city = trim ($city);

	return 'Мне нужно ИМЯ города.' if ($city eq '');
	return 'Длинновато для названия города.' if (length($city) > 80);

	$city = ucfirst ($city);
	my $w = __weather ($city);
	my $reply;

	if ($w) {
		if ($w->{temperature_min} == $w->{temperature_max}) {
			$reply = sprintf ("Погода в городе %s, %s:\n%s, ветер %s %s м/c, температура %s°C, ощущается как %s°C, относительная влажность %s%%, давление %s мм.рт.с",
				$w->{name},
				$w->{country},
				ucfirst ($w->{description}),
				$w->{wind_direction},
				$w->{wind_speed},
				$w->{temperature_min},
				$w->{temperature_feelslike},
				$w->{humidity},
				$w->{pressure}
			);
		} else {
			$reply = sprintf ("Погода в городе %s, %s:\n%s, ветер %s %s м/c, температура %s-%s°C, ощущается как %s°C, относительная влажность %s%%, давление %s мм.рт.ст",
				$w->{name},
				$w->{country},
				ucfirst ($w->{description}),
				$w->{wind_direction},
				$w->{wind_speed},
				$w->{temperature_min},
				$w->{temperature_max},
				$w->{temperature_feelslike},
				$w->{humidity},
				$w->{pressure}
			);
		}
	} else {
		$reply = "Я не знаю, какая погода в $city";
	}

	return $reply;
}

sub __weather {
	my $city = shift;
	$city = __urlencode ($city);
	my $id = md5_base64 ($city);
	my $appid = $c->{openweathermap}->{appid};
	my $now = time ();
	my $fc;
	my $w;

	# attach to cache data
	tie my %cachetime, 'DB_File', $c->{openweathermap}->{cachetime} or do {
		carp "[ERROR] Something nasty happen when cachetime ties to its data: $OS_ERROR";
		return undef;
	};

	tie my %cachedata, 'DB_File', $c->{openweathermap}->{cachedata} or do {
		carp "[ERROR] Something nasty happen when cachedata ties to its data: $OS_ERROR";
		return undef;
	};

	# lookup cache
	if (defined ($cachetime{$id}) && ($now - $cachetime{$id}) < 10800) {
		$fc = decode_json ($cachedata{$id});
	} else {
		my $r;

		# try 3 times and giveup
		for (1..3) {
			next if ($r->{success});
			my $http = HTTP::Tiny->new (timeout => 3);
			$r = $http->get (sprintf ('http://api.openweathermap.org/data/2.5/weather?q=%s&lang=ru&APPID=%s', $city, $appid));
			sleep 2;
		}

		# all 3 times can give error, so check it here
		if ($r->{success}) {
			$fc = eval { decode_json ($r->{content}) };

			if ($EVAL_ERROR) {
				carp "[WARN] openweathermap returns corrupted json: $EVAL_ERROR";
				untie %cachetime;
				untie %cachedata;
				return undef;
			};

			$cachetime{$id} = $now;
			$cachedata{$id} = encode_json ($fc);
		} else {
			untie %cachetime;
			untie %cachedata;
			return undef;
		}
	}

	untie %cachetime;
	untie %cachedata;

	# TODO: check all of this for existance
	$w->{'name'} = $fc->{name};
	$w->{'state'} = $fc->{state};
	$w->{'country'} = $fc->{sys}->{country};
	$w->{'longitude'} = $fc->{coord}->{lon};
	$w->{'latitude'} = $fc->{coord}->{lat};
	$w->{'temperature_min'} = int ($fc->{main}->{temp_min} - 273.15);
	$w->{'temperature_max'} = int ($fc->{main}->{temp_max} - 273.15);
	$w->{'temperature_feelslike'} = int ($fc->{main}->{feels_like} - 273.15);
	$w->{'humidity'} = $fc->{main}->{humidity};
	$w->{'pressure'} = int ($fc->{main}->{pressure} * 0.75006375541921);
	$w->{'description'} = $fc->{weather}->[0]->{description};
	$w->{'wind_speed'} = $fc->{wind}->{speed};
	$w->{'wind_direction'} = 'разный';
	my $dir = int ($fc->{wind}->{deg} + 0);

	if ($dir == 0) {
		$w->{'wind_direction'} = 'северный';
	} elsif ($dir > 0   && $dir <= 30) {
		$w->{'wind_direction'} = 'северо-северо-восточный';
	} elsif ($dir > 30  && $dir <= 60) {
		$w->{'wind_direction'} = 'северо-восточный';
	} elsif ($dir > 60  && $dir <  90) {
		$w->{'wind_direction'} = 'восточно-северо-восточный';
	} elsif ($dir == 90) {
		$w->{'wind_direction'} = 'восточный';
	} elsif ($dir > 90  && $dir <= 120) {
		$w->{'wind_direction'} = 'восточно-юго-восточный';
	} elsif ($dir > 120 && $dir <= 150) {
		$w->{'wind_direction'} = 'юговосточный';
	} elsif ($dir > 150 && $dir <  180) {
		$w->{'wind_direction'} = 'юго-юго-восточный';
	} elsif ($dir == 180) {
		$w->{'wind_direction'} = 'южный';
	} elsif ($dir > 180 && $dir <= 210) {
		$w->{'wind_direction'} = 'юго-юго-западный';
	} elsif ($dir > 210 && $dir <= 240) {
		$w->{'wind_direction'} = 'юго-западный';
	} elsif ($dir > 240 && $dir <  270) {
		$w->{'wind_direction'} = 'западно-юго-западный';
	} elsif ($dir == 270) {
		$w->{'wind_direction'} = 'западный';
	} elsif ($dir > 270 && $dir <= 300) {
		$w->{'wind_direction'} = 'западно-северо-западный';
	} elsif ($dir > 300 && $dir <= 330) {
		$w->{'wind_direction'} = 'северо-западный';
	} elsif ($dir > 330 && $dir <  360) {
		$w->{'wind_direction'} = 'северо-северо-западный';
	} elsif ($dir == 360) {
		$w->{'wind_direction'} = 'северный';
	}

	return $w;
}

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

	return $myphrase[rand ($#myphrase -1)];
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
		my $city = substr ($text, 3);
		$reply = weather ($city);
	} elsif (substr ($text, 1) eq 'lat'  ||  substr ($text, 1) eq 'лат') {
		$reply = latAnswer ();
	} elsif ((length ($text) >= 6 && (substr ($text, 1, 6) eq 'karma ' || substr ($text, 1, 6) eq 'карма '))  ||  substr($text, 1) eq 'karma'  ||  substr($text, 1) eq 'карма') {
		my $mytext = '';

		if (length($text) > 6) {
			$mytext = substr ($text, 7);
			chomp ($mytext);
			$mytext = trim ($mytext);
		} else {
			$mytext = '';
		}

		$reply = karmaGet ($chatid, $mytext);
	} elsif (substr ($text, 1) eq 'friday'  ||  substr ($text, 1) eq 'пятница') {
		$reply = friday ();
	} elsif (substr ($text, 1) eq 'fortune'  ||  substr ($text, 1) eq 'фортунка'  ||  substr ($text, 1) eq 'f'  ||  substr ($text, 1) eq 'ф') {
		$reply = fortune ();
	} elsif (substr ($text, 1) eq 'f 1'  ||  substr ($text, 1) eq 'fortune 1'  ||  substr ($text, 1) eq 'фортунка 1'  ||  substr ($text, 1) eq 'ф 1') {
		$reply = fortune_toggle ($chatid, 1);
	} elsif (substr ($text, 1) eq 'f 0'  ||  substr ($text, 1) eq 'fortune 0'  ||  substr ($text, 1) eq 'фортунка 0'  ||  substr ($text, 1) eq 'ф 0') {
		$reply = fortune_toggle ($chatid, 0);
	} elsif (substr ($text, 1) eq 'f ?'  ||  substr ($text, 1) eq 'fortune ?'  ||  substr ($text, 1) eq 'фортунка ?'  ||  substr ($text, 1) eq 'ф ?') {
		$reply = fortune_status ($chatid);
	} elsif (substr ($text, 1) eq 'dig' || substr ($text, 1) eq 'копать') {
		$reply = dig ($highlight);
		$msg->replyMd ($reply);
		return;
	} elsif (substr ($text, 1) eq 'help'  ||  substr ($text, 1) eq 'помощь') {
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
	$username = $msg->from->username if ($msg->from->can ('username') && defined($msg->from->username));

	if ($msg->from->can ('first_name') && defined ($msg->from->first_name)) {
		$fullname = $msg->from->first_name;

		if ($msg->from->can ('last_name') && defined ($msg->from->last_name)) {
			$fullname .= ' ' . $msg->from->last_name;
		}
	} elsif ($msg->from->can ('last_name') && defined ($msg->from->last_name)) {
		$fullname .= $msg->from->last_name;
	}

	if (defined ($username)) {
		$visavi .= '@' . $username;

		if (defined ($fullname)) {
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
1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
