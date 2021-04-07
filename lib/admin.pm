package admin;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck croak);
use CHI;
use CHI::Driver::BerkeleyDB;
use conf qw (loadConf);
use util qw (utf2sha1);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
# to export array we need @ISA here
our @ISA    = qw / Exporter /; ## no critic (ClassHierarchies::ProhibitExplicitISA)
our @EXPORT_OK = qw (@forbiddenMessageTypes @pluginList getForbiddenTypes addForbiddenType delForbiddenType listForbidden fortune_toggle fortune_toggle_list fortune_status plugin_toggle plugin_status pluginEnabled);

my $c = loadConf ();
my $cachedir = $c->{cachedir};
# this list is not yet used
our @pluginList = qw (oboobs obutts); ## no critic (Variables::ProhibitPackageVars)
our @forbiddenMessageTypes = qw (audio voice photo video video_note animation sticker dice game poll document); ## no critic (Variables::ProhibitPackageVars)

sub getForbiddenTypes {
	my $chatid = shift;

	unless (-d $dir) {
		unless (make_path $dir) {
			cluck "Unable to create $dir: $OS_ERROR";
			return;
		}
	}

	my $messageTypes;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid)
	);

	foreach (@forbiddenMessageTypes) {
		my $type = $c->get ($_);

		if ($type) {
			$messageTypes->{$_} = 1;
		} else {
			unless (defined $type) {
				$c->set ($_, 1, 'never');
				$messageTypes->{$_} = 1;
			} else {
				$messageTypes->{$_} = 0;
			}
		}
	}

	return $messageTypes;
}

sub addForbiddenType {
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

sub delForbiddenType {
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

sub listForbidden {
	my $chatid = shift;
	my @list;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid)
	);

	foreach (@forbiddenMessageTypes) {
		my $type = $c->get ($_);

		if ($type) {
			push @list, sprintf 'Тип сообщения %s удаляется', $_;
		} else {
			unless (defined $type) {
				push @list, sprintf 'Тип сообщения %s удаляется', $_;
				$c->set ($_, 1, 'never');
			} else {
				push @list, sprintf 'Тип сообщения %s не удаляется', $_;
			}
		}
	}

	return join "\n", @list;
}

sub fortune_toggle (@) {
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

sub fortune_status ($) {
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

sub fortune_toggle_list () {
	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune'
	);

	my @list = $cache->get_keys();
	return @list;
}

sub plugin_status (@) {
	my $chatid = shift;
	my $plugin = shift;
	my $phrase = "Плагин $plugin ";

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid)
	);

	my $state = $cache->get ($plugin);

	if (defined $state && $state) {
		$phrase .= 'включён.';
	} else {
		$phrase .= 'выключен.';
	}

	return $phrase;
}

sub pluginEnabled (@) {
	my $chatid = shift;
	my $plugin = shift;

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

sub plugin_toggle (@) {
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
