package BotLib::Gamestat;
# Stores and calculates player stats for games

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use DBI;
use English qw ( -no_match_vars );
use File::Path qw (make_path);
use String::Random qw (random_string);

use BotLib::Conf qw (LoadConf);
use BotLib::Util qw (trim utf2sha1);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (SeedArtifacts);


my $c = LoadConf ();
my $dir = $c->{gamestat}->{dir};
my $gamestatdir = $c->{gamestat}->{gamestatdir};
my $dbfile = sprintf '%s/gamestat.sqlite', $gamestatdir;

# assume that there is not too much artifacts.
sub SeedArtifacts {
	open (my $AFH, '<', "$dir/archeologic_artifacts.txt") || die "No $dir/archeologic_artifacts.txt";
	my @arch_artifacts;

	while (my $artifact = <$AFH>) {
		next if ($artifact =~ /^\s*$/);
		$artifact = trim ($artifact);
		push @arch_artifacts, $artifact;
	}

	close $AFH;

	open ($AFH, '<', "$dir/fisher_artifacts.txt") || die "No $dir/fisher_artifacts.txt";
	my @fisher_artifacts;

	while (my $artifact = <$AFH>) {
		next if ($artifact =~ /^\s*$/);
		$artifact = trim ($artifact);
		push @fisher_artifacts, $artifact;
	}

	close $AFH;
	undef $AFH;

	my $tablename = random_string ("..........");
	$tablename = utf2sha1 ($tablename);

	while ($tablename =~ /^\d/) {
		$tablename = utf2sha1 ($tablename);
	}

	$tablename =~ s/[\/_\+]/a/g;
	$tablename = lc ($tablename);

	unless (-d $gamestatdir) {
		make_path ($gamestatdir)  ||  die "Unable to create $dir: $OS_ERROR";
	}

	my $dbh = DBI->connect ("dbi:SQLite:$dbfile", '', '');
	$dbh->{sqlite_unicode} = 1;
	my $rows_affected = $dbh->do ('PRAGMA foreign_keys=ON') or die $dbh->errstr;
	$rows_affected = $dbh->do ('PRAGMA journal_mode=WAL') or die $dbh->errstr;

	# Open transaction
	$dbh->begin_work or die $dbh->errstr;

	$rows_affected = $dbh->do (
		qq {
			CREATE TABLE IF NOT EXISTS $tablename (
				id INT UNIQUE NOT NULL, -- artifact id
				name TEXT PRIMARY KEY   -- artifact name
			);
		}
	) or die $dbh->errstr;

	my $sth = $dbh->prepare ("REPLACE INTO $tablename(id,name) VALUES (?,?)") or die $dbh->errstr;

	# Insert our archeological artifacts
	my $c = 0;

	foreach my $artifact (@arch_artifacts) {
		last if ($c == 10000);
		$sth->execute ($c, $artifact);
		$c++;
	}

	# Insert our fishing artifacts
	$c = 10000;

	foreach my $artifact (@fisher_artifacts) {
		last if ($c == 20000);
		$sth->execute ($c, $artifact);
		$c++;
	}

	# Add indexes
	$rows_affected = $dbh->do ("CREATE INDEX IF NOT EXISTS myartifactid ON $tablename(id)") or die $dbh->errstr;

	# Drop target table and replace it with our
	$rows_affected = $dbh->do ("DROP TABLE IF EXISTS artifacts") or die $dbh->errstr;
	$rows_affected = $dbh->do ("ALTER TABLE $tablename RENAME TO artifacts") or die $dbh->errstr;

	# Close transaction
	$dbh->commit or die $dbh->errstr;
	$dbh->disconnect or warn (sprintf '[WARN] Unable to close gamestat db, sqlite error: %s', $dbh->errstr);
	return;
}

1;
