package imgur;

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

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (imgur);

my $c = loadConf ();
my $dir = $c->{image}->{dir};
my $imgur_client_id     = $c->{image}->{imgur}->{client_id};
my $imgur_client_secret = $c->{image}->{imgur}->{client_secret};
my $imgur_access_token  = $c->{image}->{imgur}->{access_token};;
my $imgur_refresh_token = $c->{image}->{imgur}->{refresh_token};

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

1;