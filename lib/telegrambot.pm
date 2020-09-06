package telegrambot;

use strict;
use warnings "all";
use vars qw/$VERSION/;
use v5.10.0;
use utf8;
use Data::Dumper;
use open qw(:std :utf8);
use File::Path qw( mkpath );
use Hailo;
use Encode;
use Mojo::Base 'Telegram::Bot::Brain';

use conf;
use botlib;

use Exporter qw(import);
our @EXPORT = qw(run_telegrambot);

$VERSION = "1.0";

my $c = loadConf();
my $hailo;

has token => $c->{telegrambot}->{token};

sub __cron {
	my $self = shift;
# noop
	return;
}

sub __on_msg {
	my ($self, $msg) = @_;

	if ($msg->{'new_chat_members'}) {
		# we have newcommers here
		$msg->reply("Дратути. Представьтес, пожалуйста, и расскажите, что вас сюда привело.");
		return;
	}

# lazy init chat-bot brains
	unless (defined($hailo->{$msg->chat->id})) {
		$hailo->{$msg->chat->id} = Hailo->new(
# we'll got file like this: data/telegrambot-brains/-1001332512695.brain.sqlite
			brain => sprintf("%s/%s.brain.sqlite", $c->{telegrambot}->{braindir}, $msg->chat->id),
			order => 3
		);
	}

# is this a 1-on-1 ?
	if ($msg->chat->type eq 'private') {
		return unless(defined($msg->text));
		my $text = $msg->text;
		my $csign = quotemeta($c->{telegrambot}->{csign});
		my $reply;

		if (substr($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr($text, 1) eq "ping") {
				$reply = "Pong.";
			} elsif (substr($text, 1) eq "пинг") {
				$reply = "Понг.";
			} elsif (substr($text, 1, 1) eq 'w' || substr($text, 1, 1) eq 'п') {
				my $city = substr($text, 2);
				$reply = weather($city);
			} else {
				$reply = "Чего?";
			}
		} else {
			$reply = $hailo->{$msg->chat->id}->learn_reply($text);
		}

		if (defined($reply) && $reply ne '') {
			$msg->reply($reply);
			logger ("private chat reply: $reply");
		} else {
# if we have no answer, say something default in private chat
			$msg->reply("Давайте ещё пообщаемся, а то я ещё не научилась от вас плохому.");
		}
# group chat
	} elsif (($msg->chat->type eq 'supergroup') or ($msg->chat->type eq 'group')) {
		my $reply;
		return unless(defined($msg->text));
		my $text = $msg->text;
# sometimes shit happens?
		return unless(defined($text));

		my $qname = quotemeta($c->{telegrambot}->{name});
		my $qtname = quotemeta($c->{telegrambot}->{tname});
		my $csign = quotemeta($c->{telegrambot}->{csign});

# simple commands
		if (substr($text, 0, 1) eq $c->{telegrambot}->{csign}) {
			if (substr($text, 1) eq "help") {
				$reply = '```
!help | !помощь     - список команд
!w город | !п город - погода в указанном городе
!ping | !пинг       - попинговать бота
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
';
			} elsif (substr($text, 1) eq "ping") {
				$reply = "Pong.";
			} elsif (substr($text, 1) eq "пинг") {
				$reply = "Понг.";
			} elsif (substr($text, 1) eq "pong") {
				$reply = "Wat?";
			} elsif (substr($text, 1) eq "понг") {
				$reply = "Шта?";
			} elsif (substr($text, 1, 2) eq 'w ' || substr($text, 1, 2) eq 'п ') {
				my $city = substr($text, 3);
				$reply = weather($city);
			}
		} elsif (
				($text eq $qname) or
				($text eq sprintf("%s", $qtname)) or
				($text eq sprintf("@%s_bot", $qname)) or # :(
				($text eq sprintf("%s ", $qtname))
			) {
				$reply = "Чего?";
		} else {
# phrase directed to bot
			if ((lc($text) =~ /^${qname}[\,|\:]? (.+)/) or (lc($text) =~ /^${qtname}[\,|\:]? (.+)/)){
				$reply = $hailo->{$msg->chat->id}->learn_reply($1);
# bot mention by name
			} elsif ((lc($text) =~ /.+ ${qname}[\,|\!|\?|\.| ]/) or (lc($text) =~ / $qname$/)) {
				$reply = $hailo->{$msg->chat->id}->reply($text);
# bot mention by telegram name
			} elsif ((lc($text) =~ /.+ ${qtname}[\,|\!|\?|\.| ]/) or (lc($text) =~ / $qtname$/)) {
				$reply = $hailo->{$msg->chat->id}->reply($text);
# just message in chat
			} else {
				$hailo->{$msg->chat->id}->learn($text);
			}
		}

		if (defined($reply) && $reply ne '') {
			logger ("reply with: $reply");
			$msg->reply($reply);
		} else {
			logger ("no reply");
		}
# should be channel, so we can't talk
	} else {
		return;
	}

	return;
}

# setup our bot
sub init {
	unless (-d $c->{telegrambot}->{braindir}) {
		mkpath ($c->{telegrambot}->{braindir}, 0, 0755);
	}

	my $self = shift;
	$self->add_listener(\&__on_msg);
#	$self->add_repeating_task(900, \&__cron);
}

sub run_telegrambot {
	while (sleep 3) {
		eval {
			telegrambot->new->think;
		}
	}
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
