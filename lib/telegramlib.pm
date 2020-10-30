package telegramlib;
# store here functions that are not implemented in Teapot::Bot

use 5.018;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

use botlib qw(trim);
use Teapot::Bot::Brain;

# module shit
use vars qw/$VERSION/;
use Exporter qw(import);
our @EXPORT_OK = qw(visavi);

$VERSION = '1.0';

sub visavi {
	my ($userid, $username, $fullname) = @_;
	my $name = '';

	if (defined ($username)) {
		$name .= '@' . $username;
		$name .= ', ' . $fullname if (defined ($fullname));
	} else {
		$name .= $fullname;
	}

	$name .= " ($userid)";
	return $name;
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
