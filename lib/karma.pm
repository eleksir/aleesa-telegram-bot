package karma;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use English qw( -no_match_vars );
use Digest::SHA1;
use DB_File;

use vars qw/$VERSION/;
use Exporter qw(import);
our @EXPORT_OK = qw(karmaSet karmaGet);

$VERSION = '1.0';

use File::Basename qw(dirname);
use File::Path qw(mkpath);
use conf qw(loadConf);
use botlib qw(logger);

my $c = loadConf();
my $karmadir = $c->{karma}->{dir};
my $max = 5;

# swallow phrase and return answer
sub karmaSet (@) {
	my $chatid = shift;
	my $phrase = shift;
	my $action = shift;
	my $score = 0;
	my $karmafile = sprintf "$karmadir/%s.db", sha1_base64 ($chatid);
	# init hash, store phrase and score
	tie my %karma, 'DB_File', $karmafile or do {
		logger "Something nasty happen when cachedata ties to its data: $OS_ERROR";
		return sprintf 'Карма %s составляет 0', $phrase;
	};

	my $sha1_phrase = sha1($phrase);

	if (defined $karma{$sha1_phrase}) {
		if ($action eq '++') {
			$score = $karma{$sha1_phrase} + 1;
			$karma{$sha1_phrase} = $score;
		} else {
			$score = $karma{$sha1_phrase} - 1;
			$karma{$sha1_phrase} = $score;
		}
	} else {
		if ($action eq '++') {
			$karma{$sha1_phrase} = 1;
		} else {
			$karma{$sha1_phrase} = -1;
		}
	}

	untie %karma;

	if ($score < 0 && (($score % $max) - 1) == 0)) {
		return sprintf 'Зарегистрировано пробитие дна, карма %s составляет %d', $phrase, $score;
	} else {
		return sprintf 'Карма %s составляет %d', $phrase, $score;
	}
}

# just return answer
sub karmaGet (@) {
	my $chatid = shift;
	my $phrase = shift;

	my $karmafile = sprintf "$karmadir/%s.db", sha1_base64 ($chatid);
	# init hash, store phrase and score
	tie my %karma, 'DB_File', $karmafile or do {
		logger "Something nasty happen when karma ties to its data: $OS_ERROR";
		return sprintf 'Карма %s составляет 0', $phrase;
	};

	my $sha1_phrase = sha1 ($phrase);
	my $score = $karma{$sha1_phrase};
	untie %karma;

	unless (defined $score) {
		$score = 0;
	}

	return sprintf 'Карма %s составляет %d', $phrase, $score;
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
