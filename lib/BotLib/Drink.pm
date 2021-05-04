package BotLib::Drink;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use CHI;
use CHI::Driver::BerkeleyDB;
use DateTime;
use English qw ( -no_match_vars );
use Encode;
use Carp qw (cluck);
use HTML::TokeParser;
use Log::Any qw ($log);
use Mojo::Log;
use Mojo::UserAgent::Cached;
use POSIX qw (strftime);
use BotLib::Conf qw (LoadConf);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Drink);

my @MONTH = qw (yanvar fevral mart aprel may iyun iyul avgust sentyabr oktyabr noyabr dekabr);
my $c = LoadConf ();
my $cachedir = $c->{cachedir};

sub Drink {
	my $r;
	my $ret = 'Не знаю праздников - вджобываю весь день на шахтах, как проклятая.';
	my ($dayNum, $monthNum) = (localtime ())[3, 4];
	my $url = sprintf 'https://kakoysegodnyaprazdnik.ru/baza/%s/%s', $MONTH[$monthNum], $dayNum;

	# Those POSIX assholes just forgot to add unix timestamps without TZ offset, so...
	my ($mday, $mon, $year) = (gmtime ())[3, 4, 5];
	my $offset = strftime ('%z', gmtime ());
	my $offsetMinutes = (substr $offset, -2) * 60;
	my $offsetHours = (substr $offset, 1, 2) * 60 * 60;
	my $offsetSign;

	if ((substr $offset, 0, 1) eq '+') {
		$offsetSign = 1;
	}

	my $expirationDate = DateTime->new (
		year => $year + 1900,
		month => $mon + 1,
		day => $mday,
		hour => 0,
		minute => 0,
		second => 0
	)->add (days => 1)->strftime ('%s');

	if ((substr $offset, 0, 1) eq '+') {
		$expirationDate = $expirationDate - $offsetHours - $offsetMinutes;
	} else {
		$expirationDate = $expirationDate + $offsetHours + $offsetMinutes;
	}

	for (1..3) {
		my $ua = Mojo::UserAgent::Cached->new->connect_timeout (3);
		$ua->cache_agent(
				CHI->new (
				driver             => 'BerkeleyDB',
				root_dir           => $cachedir,
				namespace          => __PACKAGE__,
				expires_at         => $expirationDate,
				expires_on_backend => 1,
			)
		);
		# just to make Mojo::UserAgent::Cached happy
		$ua->logger (Mojo::Log->new (path => '/dev/null', level => 'error'));
		$r = $ua->get ($url => {'Accept-Language' => 'ru-RU', 'Accept-Charset' => 'utf-8'})->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	if ($r->is_success) {
		my $p = HTML::TokeParser->new(\$r->body);
		my @a;
		my @holyday;

		do {
			$#a = -1;
			@a = $p->get_tag('span'); ## no critic (Variables::RequireLocalizedPunctuationVars)

			if ($#{$a[0]} > 2 && defined $a[0][1]->{itemprop} && $a[0][1]->{itemprop} eq 'text') {
				push @holyday,'* ' . decode ('UTF-8', $p->get_trimmed_text ('/span'));
			}

		} while ($#{$a[0]} > 1);

		if ($#holyday > 0) {
			# cut off something weird, definely not a "holyday"
			$#holyday = $#holyday - 1;
		}

		if ($#holyday > 0) {
			$ret = join "\n", @holyday;
		}
	} else {
		$log->warn (sprintf '[WARN] Kakoysegodnyaprazdnik server return status %s with message: %s', $r->code, $r->message);
	}

	return $ret;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
