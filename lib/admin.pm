package admin;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck croak);
use File::Path qw (make_path);
use SQLite_File;
use conf qw (loadConf);
use util qw (utf2sha1);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @ISA    = qw / Exporter /; ## no critic (ClassHierarchies::ProhibitExplicitISA)
our @EXPORT_OK = qw (@forbiddenMessageTypes getForbiddenTypes addForbiddenType delForbiddenType listForbidden fortune_toggle fortune_toggle_list fortune_status);

my $c = loadConf ();
my $dir = $c->{admin}->{dir};
my @forbiddenMessageTypes = qw (audio voice photo video video_note animation sticker dice game poll document);

sub initCensorDB {
	my $backingfile = shift;

	tie my %censor, 'SQLite_File', $backingfile  ||  cluck "Unable to tie to $backingfile: $OS_ERROR";

	foreach (@forbiddenMessageTypes) {
		$censor($_) = 0;
	}

	untie %censor;

	return;
}

sub getForbiddenTypes {
	my $chatid = shift;

	my $messageTypes;
	my $backingfile = utf2sha1 $chatid;
	$backingfile =~ s/\//-/xmsg;
	$backingfile = sprintf '%s/censor_%s.db', $dir, $backingfile;

	unless (-f $backingfile) {
		initCensorDB ($backingfile);
	}

	unless (tie my %censor, 'SQLite_File', $backingfile) {
		cluck "Unable to tie to $backingfile: $OS_ERROR";
		return $messageTypes;
	}

	foreach (keys %censor) {
		if ($censor{$_}) {
			$messageTypes->{$_} = 1;
		} else {
			$messageTypes->{$_} = 0;
		}
	}

	untie %censor;
	return $messageTypes;
}

sub addForbiddenType {
	my $chatid = shift;
	my $type = shift;

	unless (-d $dir) {
		unless (make_path $dir) {
			cluck "Unable to create $dir: $OS_ERROR";
			return;
		}
	}

	my $backingfile = utf2sha1 $chatid;
	$backingfile =~ s/\//-/xmsg;
	$backingfile = sprintf '%s/censor_%s.db', $dir, $backingfile;

	unless (-f $backingfile) {
		initCensorDB ($backingfile);
	}

	unless (tie my %censor, 'SQLite_File', $backingfile) {
		cluck "Unable to tie to $backingfile: $OS_ERROR";
		return;
	}

	$censor{$type} = 1;
	untie %censor;

	return;
}

sub delForbiddenType {
	my $chatid = shift;
	my $type = shift;

	unless (-d $dir) {
		unless (make_path $dir) {
			cluck "Unable to create $dir: $OS_ERROR";
			return;
		}
	}

	my $backingfile = utf2sha1 $chatid;
	$backingfile =~ s/\//-/xmsg;
	$backingfile = sprintf '%s/censor_%s.db', $dir, $backingfile;

	unless (-f $backingfile) {
		initCensorDB ($backingfile);
		return;
	}

	unless (tie my %censor, 'SQLite_File', $backingfile) {
		cluck "Unable to tie to $backingfile: $OS_ERROR";
		return;
	}

	$censor{$type} = 0;
	untie %censor;

	return;
}

sub listForbidden {
	my $chatid = shift;

	my @list;
	my $backingfile = utf2sha1 $chatid;
	$backingfile =~ s/\//-/xmsg;
	$backingfile = sprintf '%s/censor_%s.db', $dir, $backingfile;

	unless (-f $backingfile) {
		initCensorDB ($backingfile);
	}

	# FIXME: return list with all types alowed
	unless (tie my %censor, 'SQLite_File', $backingfile) {
		cluck "Unable to tie to $backingfile: $OS_ERROR";
		return '';
	}

	foreach (keys %censor) {
		if ($censor{$_}) {
			push @list, sprintf 'Тип сообщения %s удаляется', $_;
		} else {
			push @list, sprintf 'Тип сообщения %s не удаляется', $_;
		}
	}

	untie %censor;

	return join "\n", @list;
}

sub fortune_toggle (@) {
	my $chatid = shift;
	my $action = shift // undef;
	my $phrase = 'Фортунка с утра ';

	unless (-d $dir) {
		make_path ($dir)  ||  do {
			cluck "[ERROR] Unable to create $dir: $OS_ERROR";
			return;
		};
	}

	my $backingfile = sprintf '%s/chats.sqlite', $dir;

	tie my %toggle, 'SQLite_File', $backingfile  ||  do {
		cluck "[ERROR] Unable to tie to $backingfile: $OS_ERROR";
		return;
	};

	my $state = $toggle{$chatid};

	if (defined $action) {
		if ($action) {
			$toggle{$chatid} = 1;
			$phrase .= 'будет показываться.';
		} else {
			if (defined $state) {
				delete $toggle{$chatid};
			}

			$phrase .= 'не будет показываться.';
		}
	} else {
		if (defined $state && $state) {
			delete $toggle{$chatid};
			$phrase .= 'не будет показываться.';
		} else {
			$toggle{$chatid} = 1;
			$phrase .= 'будет показываться.';
		}
	}

	untie %toggle;
	return $phrase;
}

sub fortune_status ($) {
	my $chatid = shift;
	my $phrase = 'Фортунка с утра ';

	unless (-d $dir) {
		make_path ($dir)  ||  do {
			cluck "[ERROR] Unable to create $dir: $OS_ERROR";
			return;
		};
	}

	my $backingfile = sprintf '%s/chats.sqlite', $dir;

	tie my %toggle, 'SQLite_File', $backingfile  ||  do {
		cluck "[ERROR] Unable to tie to $backingfile: $OS_ERROR\n";
		return;
	};

	my $state = $toggle{$chatid};

	if (defined $state && $state) {
		$phrase .= 'показывается.';
	} else {
		$phrase .= 'не показывается.';
	}

	untie %toggle;
	return $phrase;
}

sub fortune_toggle_list () {
	unless (-d $dir) {
		make_path ($dir)  ||  do {
			cluck "[ERROR] Unable to create $dir: $OS_ERROR";
			my @empty = ();
			return @empty;
		}
	}

	my $backingfile = sprintf '%s/chats.sqlite', $dir;

	tie my %toggle, 'SQLite_File', $backingfile  ||  do {
		cluck "[ERROR] Unable to tie to $backingfile: $OS_ERROR";
		my @empty = ();
		return @empty;
	};

	my @list = keys %toggle;
	untie %toggle;
	return @list;
}


1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
