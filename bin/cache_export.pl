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
my $exportInst = 0;

sub dumpCache {
	my $namespace = shift;
	my $cacheExportDir = sprintf '%s/cacheexport', $datadir;

	unless (-d $cacheExportDir) {
		make_path ($cacheExportDir)  ||  die "Unable to create $cacheExportDir: $OS_ERROR\n";
	}

	my $filename = sprintf '%s/%s', $cacheExportDir, $exportInst;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => $namespace
	);

	my $j;
	my $writefile = 0;

	foreach my $k ($cache->get_keys ()) {
		$k = decode ('UTF-8', $k);
		$j->{$k} = decode ('UTF-8', $cache->get ($k));
		$writefile = 1;
	}

	if ($writefile) {
		say "Dumping $namespace";  ## no critic (InputOutput::RequireCheckedSyscalls)
		my $jsonencoder = JSON::XS->new->pretty ();
		open (my $FILE, '>', $filename) or die "Unable to dump cache namespace $namespace to $filename: $OS_ERROR\n";
		print $FILE $jsonencoder->encode ($j) or die "Unable to dump cache namespace $namespace to $filename: $OS_ERROR\n";;
		close $FILE; ## no critic (InputOutput::RequireCheckedSyscalls)
		my $EXPORTFD;

		if ($export) {
			open ($EXPORTFD, '>>', "$cacheExportDir/exportfiles.txt") or die "Unable to open for appending $cacheExportDir/exportfiles.txt: $OS_ERROR\n";
		} else {
			open ($EXPORTFD, '>', "$cacheExportDir/exportfiles.txt") or die "Unable to create $cacheExportDir/exportfiles.txt: $OS_ERROR\n";
			$export = 1;
		}

		printf ($EXPORTFD "%s,%s\n", $namespace, $filename) or die "Unable to write to $cacheExportDir/exportfiles.txt: $OS_ERROR\n";
		close $EXPORTFD; ## no critic (InputOutput::RequireCheckedSyscalls)
		$exportInst++;
	}

	return;
}

opendir (my $DIR, $cachedir) or die "Unable to open $cachedir: $OS_ERROR\n";

while (readdir $DIR) {
	if (/^BotLib\+3a\+3aAdmin_censor_(.+)\.db$/) {
		dumpCache ("BotLib::Admin_censor_$1");
	} elsif (/^BotLib\+3a\+3aAdmin_fortune.db$/) {
		dumpCache ('BotLib::Admin_fortune');
	} elsif (/BotLib\+3a\+3aAdmin_plugin_(.+)\.db$/) {
		dumpCache ("BotLib::Admin_plugin_$1");
	} elsif (/BotLib\+3a\+3aAdmin_(.+)\.db$/) {
		dumpCache ("BotLib::Admin_$1");
	} elsif (/^BotLib\+3a\+3aImage\+3a\+3aFlickr\.db$/) {
		dumpCache ('BotLib::Image::Flickr');
	} elsif (/^BotLib\+3a\+3aKarma_(.+)\.db$/) {
		dumpCache ("BotLib::Karma_$1");
	}
}

closedir $DIR;
exit 0;

