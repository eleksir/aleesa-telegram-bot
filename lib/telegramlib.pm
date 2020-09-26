package telegramlib;
# store here functions that are not implemented in Telegram::Bot

use 5.018;
use strict;
use warnings "all";
use utf8;
use open qw(:std :utf8);

use botlib qw(trim);
use Telegram::Bot::Brain;

# module shit
use vars qw/$VERSION/;
use Exporter qw(import);
our @EXPORT = qw(getChat getChatMember visavi);

$VERSION = "1.0";

# complete framework with our getChat()
sub getChat {
	my $self = shift;
	my $id = shift;
	my $send_args = {};
	$send_args->{chat_id} = $id;

	my $token = $self->token;
	my $url = "https://api.telegram.org/bot${token}/getChat";
	my $api_response = $self->_post_request ($url, $send_args);

	# we seek for permissions, when making call to this subroutine, but
	# framework does just omits it, when creating object from hash, so
	# pick raw json object instead

	#return Telegram::Bot::Object::User->create_from_hash($api_response, $self);
	return $api_response;
}

# complete framework with our getChatMember()
sub getChatMember {
	my $self = shift;
	my $chatid = shift;
	my $userid = shift;
	my $send_args = {};
	$send_args->{chat_id} = $chatid;
	$send_args->{user_id} = $userid;
	my $token = $self->token;
	my $url = "https://api.telegram.org/bot${token}/getChatMember";
	my $api_response = $self->_post_request ($url, $send_args);

	# return Telegram::Bot::Object::User->create_from_hash($api_response, $self);
	return $api_response;
}

sub visavi (@) {
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
