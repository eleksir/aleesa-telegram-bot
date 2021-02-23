package fox;

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
our @EXPORT_OK = qw (fox);

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

		if ($EVAL_ERROR) {
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

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
