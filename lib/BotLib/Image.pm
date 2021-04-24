package BotLib::Image;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck);
use Math::Random::Secure qw (irand);
use Mojo::UserAgent;
use BotLib::Image::Flickr qw (FlickrByTags);
use BotLib::Image::Imgur qw (Imgur);
use BotLib::Util qw (urlencode);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Kitty Fox Oboobs Obutts Rabbit Owl);

sub Kitty {
	my $r;
	my $ret = 'Нету кошечек, все разбежались.';

	for (1..3) {
		my $ua  = Mojo::UserAgent->new->connect_timeout (3);
		$r = $ua->get ('https://api.thecatapi.com/v1/images/search')->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	if ($r->is_success) {
		my $jcat = eval {
			return $r->json;
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
		cluck sprintf 'Server return status %s with message: %s', $r->code, $r->message;
	}

	return $ret;
}

sub Fox {
	my $r;
	my $ret = 'Нету лисичек, все разбежались.';

	for (1..3) {
		my $ua  = Mojo::UserAgent->new->connect_timeout (3);
		$r = $ua->get ('https://randomfox.ca/floof/')->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	if ($r->is_success) {
		my $jfox = eval {
			return $r->json;
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
		cluck sprintf 'Server return status %s with message: %s', $r->code, $r->message;
	}

	return $ret;
}

sub Oboobs {
	my $r;
	my $ret = 'Нету cисичек, все разбежались.';

	for (1..3) {
		my $ua  = Mojo::UserAgent->new->connect_timeout (3);
		$r = $ua->get ('http://api.oboobs.ru/boobs/0/1/random')->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	if ($r->is_success) {
		my $joboobs = eval {
			return $r->json;
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
		cluck sprintf 'Server return status %s with message: %s', $r->code, $r->message;
	}

	return $ret;
}

sub Obutts {
	my $r;
	my $ret = 'Нету попок, все разбежались.';

	for (1..3) {
		my $ua  = Mojo::UserAgent->new->connect_timeout (3);
		$r = $ua->get ('http://api.obutts.ru/butts/0/1/random')->result;

		if ($r->is_success) {
			last;
		}

		sleep 2;
	}

	if ($r->is_success) {
		my $jobutts = eval {
			return $r->json;
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
		cluck sprintf 'Server return status %s with message: %s', $r->code, $r->message;
	}

	return $ret;
}

# It works but results are not particulary relevant, partially. about 20-30% miss
# So i prefer to use flickr rabbits selection :)
sub rabbit_imgur {
	my @terms = (
		urlencode '?q=animals AND (rabbits OR bunnies)',
		urlencode 'year?q=animals AND (rabbits OR bunnies)',
		urlencode 'relevance?q=animals AND (rabbits OR bunnies)',
		urlencode 'relevance/year?q=animals AND (rabbits OR bunnies)',
		urlencode 'score?q_not=cat OR kitten OR kittens OR dog OR cats OR dogs OR puppy OR puppies&q_tags=bunnies,bunny,rabbits,rabbit',
	);

	my $rabbit = Imgur ($terms[irand ($#terms + 1)]);
	# return just large thumbnail instead of real photo (that can be really huge)
	$rabbit = sprintf '%sl%s', substr ($rabbit, 0, -4), substr ($rabbit, -4);

	if (defined $rabbit) {
		return sprintf '[(\_/)](%s)', $rabbit;
	} else {
		return 'Нету кроликов, все разбежались.'
	}
}

sub Rabbit {
	# rabbit, but bunny
	my $url = FlickrByTags ('animal,bunny');

	if (defined $url) {
		return sprintf '[(\_/)](%s)', $url;
	} else {
		return 'Нету кроликов, все разбежались.';
	}
}

sub Owl {
	my $url = FlickrByTags ('bird,owl');

	if (defined $url) {
		return sprintf '[{ O v O }](%s)', $url;
	} else {
		return 'Нету сов, все разлетелись.';
	}
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
