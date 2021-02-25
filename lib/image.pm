package image;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck);
use JSON::XS;
use HTTP::Tiny;
use Math::Random::Secure qw (irand);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (kitty fox oboobs obutts);

sub kitty {
	my $r;
	my $ret = 'Нету кошечек, все разбежались.';

	for (1..3) {
		my $http = HTTP::Tiny->new (timeout => 3);
		$r = $http->get ('https://api.thecatapi.com/v1/images/search');

		if ($r->{success}) {
			last;
		}

		sleep 2;
	}

	if ($r->{success}) {
		my $jcat = eval {
			decode_json ($r->{content})
		};

		unless (defined $jcat) {
			cluck "[ERROR] Unable to decode JSON: $EVAL_ERROR";
		} else {
			if ($jcat->[0]->{url}) {
				my @cats = ('龴ↀ◡ↀ龴', '=^..^=', '≧◔◡◔≦ ','^ↀᴥↀ^' );
				$ret = sprintf '[%s](%s)', $cats[irand ($#cats + 1)], $jcat->[0]->{url};
			}
		}
	} else {
		cluck sprintf 'Server return status %s with message: %s', $r->{status}, $r->{reason};
	}

	return $ret;
}

sub fox {
	my $r;
	my $ret = 'Нету лисичек, все разбежались.';

	for (1..3) {
		my $http = HTTP::Tiny->new (timeout => 3);
		$r = $http->get ('https://randomfox.ca/floof/');

		if ($r->{success}) {
			last;
		}

		sleep 2;
	}

	if ($r->{success}) {
		my $jfox = eval {
			decode_json ($r->{content})
		};

		unless (defined $jfox) {
			cluck "[ERROR] Unable to decode JSON: $EVAL_ERROR";
		} else {
			if ($jfox->{image}) {
				$jfox->{image} =~ s/\\//xmsg;
				$ret = sprintf '[-^^,--,~](%s)', $jfox->{image};
			}
		}
	} else {
		cluck sprintf 'Server return status %s with message: %s', $r->{status}, $r->{reason};
	}

	return $ret;
}

sub oboobs {
	my $r;
	my $ret = 'Нету cисичек, все разбежались.';

	for (1..3) {
		my $http = HTTP::Tiny->new (timeout => 3);
		$r = $http->get ('http://api.oboobs.ru/boobs/0/1/random');

		if ($r->{success}) {
			last;
		}

		sleep 2;
	}

	if ($r->{success}) {
		my $joboobs = eval {
			decode_json ($r->{content})
		};

		unless (defined $joboobs) {
			cluck "[ERROR] Unable to decode JSON: $EVAL_ERROR";
		} else {
			if ($joboobs->[0]->{preview}) {
				my @boobs = ('(. )( .)', '(  . Y .  )', '(o)(o)', '( @ )( @ )', '(.)(.)');
				$ret = sprintf '[%s](https://media.oboobs.ru/%s)', $boobs[irand ($#boobs + 1)], $joboobs->[0]->{preview};
			}
		}
	} else {
		cluck sprintf 'Server return status %s with message: %s', $r->{status}, $r->{reason};
	}

	return $ret;
}

sub obutts {
	my $r;
	my $ret = 'Нету попок, все разбежались.';

	for (1..3) {
		my $http = HTTP::Tiny->new (timeout => 3);
		$r = $http->get ('http://api.obutts.ru/butts/0/1/random');

		if ($r->{success}) {
			last;
		}

		sleep 2;
	}

	if ($r->{success}) {
		my $jobutts = eval {
			decode_json ($r->{content})
		};

		unless (defined $jobutts) {
			cluck "[ERROR] Unable to decode JSON: $EVAL_ERROR";
		} else {
			if ($jobutts->[0]->{preview}) {
				my @butts = ('(__(__)', '(_!_)', '(__.__)');
				$ret = sprintf '[%s](http://media.obutts.ru/%s)', $butts[irand ($#butts + 1)], $jobutts->[0]->{preview};
			}
		}
	} else {
		cluck sprintf 'Server return status %s with message: %s', $r->{status}, $r->{reason};
	}

	return $ret;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
