package image;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck);
use File::Path qw (make_path);
use JSON::XS;
use HTTP::Tiny;
use Math::Random::Secure qw (irand);
use SQLite_File;
use conf qw (loadConf);
use flickr qw (flickr_by_tags);
use util qw (urlencode);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (kitty fox oboobs obutts rabbit owl);

my $c = loadConf ();
my $dir = $c->{image}->{dir};
my $imgur_client_id     = $c->{image}->{imgur}->{client_id};
my $imgur_client_secret = $c->{image}->{imgur}->{client_secret};
my $imgur_access_token  = $c->{image}->{imgur}->{access_token};;
my $imgur_refresh_token = $c->{image}->{imgur}->{refresh_token};

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

sub imgur {
	my $tag = shift;

	my $refresh_url   = 'https://api.imgur.com/oauth2/token';
	my $search_url    = 'https://api.imgur.com/3/gallery/search/';
	my $http = HTTP::Tiny->new (timeout => 5);

	# load all tokens from api secrets db
	my $backingfile = sprintf '%s/secrets.sqlite', $dir;

	unless (-d $dir) {
		make_path ($dir) or do {
			cluck "Unable to create $dir: $OS_ERROR";
			return undef;
		};
	}

	tie my %secret, 'SQLite_File', $backingfile  ||  do {
		cluck "[ERROR] Unable to tie to $backingfile: $OS_ERROR";
		return undef;
	};

	# if there is no access_token in db - put there one from config
	if (defined $secret{imgur_access_token}) {
		$imgur_access_token = $secret{imgur_access_token};
	} else {
		$secret{imgur_access_token} = $imgur_access_token;
	}

	# if there is no refresh_token in db - put there one from config
	if (defined $secret{imgur_refresh_token}) {
		$imgur_refresh_token = $secret{imgur_refresh_token};
	} else {
		$secret{imgur_refresh_token} = $imgur_refresh_token;
	}

	# query api
	my $r = $http->get (
		$search_url . $tag,
		{
			headers => {
				Authorization => "Bearer $imgur_access_token"
			}
		}
	);

	# looks like we need to refresh token
	if (($r->{status} == 401) || ($r->{status} == 403)) {
		$r = $http->post_form (
			$refresh_url,
			{
				refresh_token => $imgur_refresh_token,
				client_id => $imgur_client_id,
				clinent_secret => $imgur_client_secret,
				grant_type => 'refresh_token',
			}
		);

		unless ($r->{success}) {
			cluck "Unable to refresh imgur token, please re-authorise app! or imgur experiencing api outage: $r->{status} $r->{content}";
			untie %secret;
			return undef;
		}

		my $refresh = eval { decode_json $r->{content} };

		if (defined $refresh) {
			$imgur_refresh_token = $refresh->{refresh_token};
			$secret{imgur_refresh_token} = $refresh->{refresh_token};
			$imgur_access_token = $refresh->{access_token};
			$secret{imgur_access_token} = $refresh->{access_token};
		} else {
			cluck "Unable to refresh imgur access_token, unable to decode json: $EVAL_ERROR";
			untie %secret;
			return undef;
		}

		# query api again
		$r = $http->get (
			$search_url . $tag,
			{
				headers => {
					Authorization => "Bearer $imgur_access_token"
				}
			}
		);
	}

	untie %secret;

	if ($r->{success}) {
		my $searchResult = eval { decode_json ($r->{content}) };
		my @urls;

		if (defined $searchResult) {
			if ($searchResult->{success}) {
				foreach my $item (@{$searchResult->{data}}) {
					foreach my $image (@{$item->{images}}) {
						if (defined ($image->{animated}) && (0 + $image->{animated}) != 0) {
							next;
						}

						if (($image->{type} eq 'image/jpeg') || ($image->{type} eq 'image/png')) {
							if (defined ($image->{is_ad}) && (0 + $image->{is_ad}) !=0) {
								next;
							}

							if (defined ($image->{nsfw}) && (0 + $image->{nsfw}) != 0) {
								next;
							}

							push @urls, $image->{link};
						}
					}
				}

				if ($#urls > 0) {
					return $urls[irand ($#urls + 1)];
				} else {
					cluck 'Imgur api returned empty result.';
					return undef;
				}
			} else {
				cluck "Unable to get results from imgur api: $r->{content}";
				return undef;
			}
		} else {
			cluck "Unable to decode imgur api json: $EVAL_ERROR";
			return undef;
		}
	} else {
		cluck "Unable to get results from imgur api: $r->{status}, $r->{content}";
		return undef;
	}
}

# It works but results are not particulary relevant, partially. about 20-30% miss
# So i prefer to use flickr rabbits selection :)
sub rabbit_imgur {
	my @terms = (
		urlencode '?q=animals AND (rabbits OR bunnies)',
		urlencode 'year?q=animals AND (rabbits OR bunnies)',
		urlencode 'relevance?q=animals AND (rabbits OR bunnies)',
		urlencode 'relevance/year?q=animals AND (rabbits OR bunnies)',
		urlencode 'score?q_not=cat OR kitten OR kittens OR dog OR cats OR dogs OR puppy OR puppies&q_tags=bunnies,bunny,rabbits,rabbit'
	);

	my $rabbit = imgur ($terms[irand ($#terms + 1)]);
	# return just large thumbnail instead of real photo (that can be really huge)
	$rabbit = sprintf '%sl%s', substr ($rabbit, 0, -4), substr ($rabbit, -4);

	if (defined $rabbit) {
		return sprintf '[(\_/)](%s)', $rabbit;
	} else {
		return 'Нету кроликов, все разбежались.'
	}
}

sub rabbit {
	# rabbit, but bunny
	my $url = flickr_by_tags ('animal,bunny');

	if (defined $url) {
		return sprintf '[(\_/)](%s)', $url;
	} else {
		return 'Нету кроликов, все разбежались.';
	}
}

sub owl {
	my $url = flickr_by_tags ('bird,owl');

	if (defined $url) {
		return sprintf '[{ O v O }](%s)', $url;
	} else {
		return 'Нету сов, все разлетелись.';
	}
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
