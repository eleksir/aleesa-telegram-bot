package BotLib::Xkcd;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use Mojo::UserAgent;

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Xkcd);

sub Xkcd {
	my $ua  = Mojo::UserAgent->new->connect_timeout (5)->max_redirects (0);
	my $r = $ua->get ('https://xkcd.ru/random/')->result;

	if (
		defined $r->content &&
		defined $r->content->headers &&
		defined $r->content->headers->location &&
		$r->content->headers->location ne ''
	) {
		return sprintf '[xkcd.ru](https://xkcd.ru/i/%s_v1.png)', substr ($r->content->headers->location, 1, -1);
	}

	return 'Комикс-стрип нарисовать не так-то просто :(';
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
