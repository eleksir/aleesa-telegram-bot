package BotLib::Weather;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (carp cluck);
use CHI;
use CHI::Driver::BerkeleyDB;
use Log::Any qw ($log);
use Mojo::Log;
use Mojo::UserAgent::Cached;
use BotLib::Conf qw (LoadConf);
use BotLib::Util qw (trim urlencode);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Weather);

my $c = LoadConf ();
my $cachedir = $c->{cachedir};

sub Weather {
	my $city = shift;
	$city = trim $city;

	return 'Мне нужно ИМЯ города.' if ($city eq '');
	return 'Длинновато для названия города.' if (length ($city) > 80);

	$city = ucfirst $city;

	if ($city eq 'Мск' || $city eq 'Default' || $city eq 'Dc' || $city eq 'Msk' || $city eq 'Dc-universe') {
		$city = 'Москва';
	} elsif ($city eq 'Спб' || $city eq 'Spb') {
		$city = 'Санкт-Петербург';
	} elsif ($city eq 'Ект' || $city eq 'Ебург' || $city eq 'Ёбург' || $city eq 'Екат' || $city eq 'Ekt' || $city eq 'Eburg' || $city eq 'Ekat') {
		$city = 'Екатеринбург';
	}

	my $w = __weather ($city);
	my $reply;

	if ($w) {
		if ($w->{temperature_min} == $w->{temperature_max}) {
			$reply = sprintf (
				"Погода в городе %s, %s:\n%s, ветер %s %s м/c, температура %s°C, ощущается как %s°C, относительная влажность %s%%, давление %s мм.рт.ст",
				$w->{name},
				$w->{country},
				ucfirst $w->{description},
				$w->{wind_direction},
				$w->{wind_speed},
				$w->{temperature_min},
				$w->{temperature_feelslike},
				$w->{humidity},
				$w->{pressure}
			);
		} elsif ($w->{temperature_min} < 0 && $w->{temperature_max} <= 0) {
			$reply = sprintf (
				"Погода в городе %s, %s:\n%s, ветер %s %s м/c, температура от %s до %s°C, ощущается как %s°C, относительная влажность %s%%, давление %s мм.рт.ст",
				$w->{name},
				$w->{country},
				ucfirst $w->{description},
				$w->{wind_direction},
				$w->{wind_speed},
				$w->{temperature_max},
				$w->{temperature_min},
				$w->{temperature_feelslike},
				$w->{humidity},
				$w->{pressure}
			);
		} else {
			$reply = sprintf (
				"Погода в городе %s, %s:\n%s, ветер %s %s м/c, температура от %s до %s°C, ощущается как %s°C, относительная влажность %s%%, давление %s мм.рт.ст",
				$w->{name},
				$w->{country},
				ucfirst $w->{description},
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
	$city = urlencode $city;
	my $appid = $c->{openweathermap}->{appid};
	my $now = time ();
	my $fc;
	my $w;

	my $r;

	# try 3 times and giveup
	for (1..3) {
		my $ua = Mojo::UserAgent::Cached->new;
		$ua->local_dir ($cachedir);
		$ua->cache_agent(
				CHI->new (
				driver             => 'BerkeleyDB',
				root_dir           => $cachedir,
				namespace          => __PACKAGE__,
				expires_in         => '3 hours',
				expires_on_backend => 1,
			)
		);
		# just to make Mojo::UserAgent::Cached happy
		$ua->logger (Mojo::Log->new (path => '/dev/null', level => 'error'));
		$r = $ua->get (sprintf ('http://api.openweathermap.org/data/2.5/weather?q=%s&lang=ru&APPID=%s', $city, $appid))->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	# all 3 times can give error, so check it here
	if ($r->is_success) {
		$fc = eval {
			return $r->json;
		};

		unless ($fc) {
			$log->warn ("[WARN] openweathermap returns corrupted json: $EVAL_ERROR");
			return undef;
		};
	} else {
		$log->warn (sprintf '[WARN] Server return status %s with message: %s', $r->code, $r->message);
		return undef;
	}

	# TODO: check all of this for existence
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

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
