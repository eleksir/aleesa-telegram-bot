package BotLib::Buni;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck);
use HTML::TokeParser;
use Mojo::UserAgent;

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Buni);

sub Buni {
	my $r;
	my $ret = 'Нету Buni';

	for (1..3) {
		my $ua  = Mojo::UserAgent->new->connect_timeout (3);
		$r = $ua->get ('http://www.bunicomic.com/?random&nocache=1')->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	if ($r->is_success) {
		my $p = HTML::TokeParser->new(\$r->body);
		my @a;

		# additional {} required in order "last" to work properly :)
		{
			do {
				$#a = -1;
				@a = $p->get_tag('meta'); ## no critic (Variables::RequireLocalizedPunctuationVars)

				if (defined $a[0][1]->{property} && $a[0][1]->{property} eq 'og:image') {
					$ret = sprintf '[buni](%s)', $a[0][1]->{content};
					last;
				}

			} while ($#{$a[0]} > 1);
		}
	} else {
		cluck sprintf 'Server return status %s with message: %s', $r->code, $r->message;
	}

	return $ret;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
