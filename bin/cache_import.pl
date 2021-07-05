#!/usr/bin/perl

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use version; our $VERSION = qw (1.0);

my $workdir;

# before we run, change working dir
BEGIN {
	use Cwd qw (chdir abs_path);
	my @CWD = split /\//xms, abs_path ($PROGRAM_NAME);
	if ($#CWD > 1) { $#CWD = $#CWD - 2; }
	$workdir = join '/', @CWD;
	chdir $workdir;
}

use lib ("$workdir/lib", "$workdir/vendor_perl", "$workdir/vendor_perl/lib/perl5");
use CHI;
use CHI::Driver::BerkeleyDB;
use File::Basename qw (dirname);
use File::Path qw (make_path);
use JSON::XS;
use Encode;

use BotLib::Conf qw (LoadConf);

my $c = LoadConf ();
my $cachedir = $c->{cachedir};
my $datadir = dirname $cachedir;
my $export = 0;

sub createCache {
	my $namespace = shift;
	my $filename = shift;
	say "Creating $namespace from $filename"; ## no critic (InputOutput::RequireCheckedSyscalls)

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => $namespace
	);

	open my $FH, '<', $filename or die "Unable to open $filename: $OS_ERROR\n";
	binmode $FH;
	my $len = (stat $filename) [7];
	my $json;
	use bytes;
	my $readlen = read $FH, $json, $len;
	no bytes;

	unless ($readlen) {
		close $FH;                                   ## no critic (InputOutput::RequireCheckedSyscalls
		die "Unable to read $filename: $OS_ERROR\n";
	}

	if ($readlen != $len) {
		close $FH;                                   ## no critic (InputOutput::RequireCheckedSyscalls
		die "File $filename is $len bytes on disk, but we read only $readlen bytes\n";
	}

	close $FH;                                       ## no critic (InputOutput::RequireCheckedSyscalls
	my $j = JSON::XS->new->utf8->relaxed;
	my $dump = $j->decode ($json);

	foreach my $key (keys (%{$dump})) {
		$cache->set ($key, $dump->{$key}, 'never');
	}

	return;
}

open (my $FH, '<', "$datadir/cacheexport/exportfiles.txt") or die "Unable to open $datadir/cacheexport/exportfiles.txt: $OS_ERROR\n";

while (<$FH>) {
	chomp;
	my ($namespace, $filename) = split /\,/, $_, 2;
	createCache ($namespace, $filename);
}

close $FH;  ## no critic (InputOutput::RequireCheckedSyscalls)
exit 0;
