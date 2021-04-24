package Botlib::Image::Imgur;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck);
use CHI;
use CHI::Driver::BerkeleyDB;
use Math::Random::Secure qw (irand);
use Mojo::UserAgent;

use BotLib::Conf qw (LoadConf);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Imgur);

my $c = LoadConf ();
my $cachedir = $c->{cachedir};

sub Imgur {
	my $tag = shift;

	my $refresh_url   = 'https://api.imgur.com/oauth2/token';
	my $search_url    = 'https://api.imgur.com/3/gallery/search/';

	my $imgur_client_id     = $c->{image}->{imgur}->{client_id} // do {
		cluck 'No client_id specified in config for imgur module';
		return undef;
	};
	my $imgur_client_secret = $c->{image}->{imgur}->{client_secret} // do {
		cluck 'No client_secret specified in config for imgur module';
		return undef;
	};
	my $imgur_access_token  = $c->{image}->{imgur}->{access_token} // do {
		cluck 'No access_token specified in config for imgur module';
		return undef;
	};
	my $imgur_refresh_token = $c->{image}->{imgur}->{refresh_token} // do {
		cluck 'No refresh_token specified in config for imgur module';
	};

	# N.B. Both imgur_access_token and imgur_refresh_token time to time can change, so we need
	#      some place where we can store new values
	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__
	);

	$imgur_access_token = $cache->get ('imgur_access_token');

	# if there is no access_token in db - put there one from config
	unless (defined $imgur_access_token) {
		$cache->set ('imgur_access_token', $c->{image}->{imgur}->{access_token}, 'never');
	}

	$imgur_refresh_token = $cache->get ('imgur_refresh_token');

	# if there is no refresh_token in db - put there one from config
	unless (defined $imgur_refresh_token) {
		$cache->set ('imgur_refresh_token', $c->{image}->{imgur}->{refresh_token}, 'never');
	}

	# query api
	my $ua = Mojo::UserAgent->new->connect_timeout (3);
	my $r = $ua->get ($search_url . $tag => {Authorization => "Bearer $imgur_access_token"})->result;

	# looks like we need to refresh token
	if (($r->code == 401) || ($r->code == 403)) {
		$ua->post (
			$refresh_url => form {
				refresh_token => $imgur_refresh_token,
				client_id => $imgur_client_id,
				clinent_secret => $imgur_client_secret,
				grant_type => 'refresh_token',
			}
		);

		unless ($r->is_success) {
			cluck "Unable to refresh imgur token, please re-authorise app! or imgur experiencing api outage: $r->code $r->message";
			return undef;
		}

		my $refresh = eval { return $r->json; };

		if (defined $refresh) {
			$imgur_refresh_token = $refresh->{refresh_token};
			$cache->set ('refresh_token', $refresh->{refresh_token}, 'never');
			$imgur_access_token = $refresh->{access_token};
			$cache->set ('imgur_access_token', $refresh->{access_token}, 'never');
		} else {
			cluck "Unable to refresh imgur access_token, unable to decode json: $EVAL_ERROR";
			return undef;
		}

		# query api again
		$r = $ua->get ($search_url . $tag => {Authorization => "Bearer $imgur_access_token"})->result;
	}

	if ($r->is_success) {
		my $searchResult = eval { return $r->json; };
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
				cluck "Unable to get results from imgur api: $r->message";
				return undef;
			}
		} else {
			cluck "Unable to decode imgur api json: $EVAL_ERROR";
			return undef;
		}
	} else {
		cluck "Unable to get results from imgur api: $r->code, $r->message";
		return undef;
	}
}

1;
