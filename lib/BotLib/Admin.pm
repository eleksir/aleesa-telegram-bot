package BotLib::Admin;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck croak);
use CHI;
use CHI::Driver::BerkeleyDB;
use BotLib::Conf qw (LoadConf);
use BotLib::Util qw (utf2sha1);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
# to export array we need @ISA here
our @ISA    = qw / Exporter /; ## no critic (ClassHierarchies::ProhibitExplicitISA)
our @EXPORT_OK = qw (@ForbiddenMessageTypes @PluginList GetForbiddenTypes AddForbiddenType DelForbiddenType
                     ListForbidden FortuneToggle FortuneToggleList FortuneStatus PluginToggle PluginStatus
                     PluginEnabled);

my $c = LoadConf ();
my $cachedir = $c->{cachedir};
# this list is not yet used
our @PluginList = qw (oboobs obutts); ## no critic (Variables::ProhibitPackageVars)
our @ForbiddenMessageTypes = qw (audio voice photo video video_note animation sticker dice game poll document); ## no critic (Variables::ProhibitPackageVars)

sub GetForbiddenTypes {
	my $chatid = shift;
	my $messageTypes;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid)
	);

	foreach (@ForbiddenMessageTypes) {
		my $type = $cache->get ($_);

		if ($type) {
			$messageTypes->{$_} = 1;
		} else {
			unless (defined $type) {
				$cache->set ($_, 0, 'never');
			}

			$messageTypes->{$_} = 0;
		}
	}

	return $messageTypes;
}

sub AddForbiddenType {
	my $chatid = shift;
	my $type = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid)
	);

	$cache->set ($type, 1, 'never');
	return;
}

sub DelForbiddenType {
	my $chatid = shift;
	my $type = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid)
	);

	$cache->remove ($type);
	return;
}

sub ListForbidden {
	my $chatid = shift;
	my @list;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid)
	);

	foreach (@ForbiddenMessageTypes) {
		my $type = $cache->get ($_);

		if ($type) {
			push @list, sprintf 'Тип сообщения %s удаляется', $_;
		} else {
			unless (defined $type) {
				$cache->set ($_, 0, 'never');
			}

			push @list, sprintf 'Тип сообщения %s не удаляется', $_;
		}
	}

	return join "\n", @list;
}

sub FortuneToggle (@) {
	my $chatid = shift;
	my $action = shift // undef;
	my $phrase = 'Фортунка с утра ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune'
	);

	my $state = $cache->get ($chatid);

	if (defined $action) {
		if ($action) {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'будет показываться.';
		} else {
			if (defined $state) {
				$cache->remove ($chatid);
			}

			$phrase .= 'не будет показываться.';
		}
	} else {
		if (defined $state && $state) {
			$cache->remove ($chatid);
			$phrase .= 'не будет показываться.';
		} else {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'будет показываться.';
		}
	}

	return $phrase;
}

sub FortuneStatus ($) {
	my $chatid = shift;
	my $phrase = 'Фортунка с утра ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune'
	);

	my $state = $cache->get ($chatid);

	if (defined $state && $state) {
		$phrase .= 'показывается.';
	} else {
		$phrase .= 'не показывается.';
	}

	return $phrase;
}

sub FortuneToggleList () {
	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune'
	);

	return $cache->get_keys ();
}

sub PluginStatus (@) {
	my $chatid = shift;
	my $plugin = shift;
	my $phrase = "Плагин $plugin ";

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid)
	);

	my $state = $cache->get ($plugin);

	if ($state) {
		$phrase .= 'включён.';
	} else {
		unless (defined $state) {
			$cache->set ($plugin, 0, 'never');
		}

		$phrase .= 'выключен.';
	}

	return $phrase;
}

sub PluginEnabled (@) {
	my $chatid = shift;
	my $plugin = shift;

	# seems that we have point to return always true if chat is private
	if ($chatid > 0) {
		return 1;
	}

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid)
	);

	my $state = $cache->get ($plugin);

	if (defined $state && $state) {
		return 1;
	} else {
		return 0;
	}
}

sub PluginToggle (@) {
	my $chatid = shift;
	my $plugin = shift;
	my $action = shift // undef;
	my $phrase = "Плагин $plugin ";

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid)
	);

	my $state = $cache->get ($plugin);

	if (defined $action) {
		if ($action) {
			$cache->set ($plugin, 1, 'never');
			$phrase .= 'включён';
		} else {
			$cache->set ($plugin, 0, 'never');
			$phrase .= 'выключен';
		}
	} else {
		if (defined ($state) && $state) {
			$cache->set ($plugin, 0, 'never');
			$phrase .= 'включён';
		} else {
			$cache->set ($plugin, 1, 'never');
			$phrase .= 'выключен';
		}
	}

	return $phrase;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
