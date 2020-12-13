#!/usr/bin/perl

use 5.018;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use English qw( -no_match_vars );
use lib qw(./lib ./vendor_perl ./vendor_perl/lib/perl5);
use JSON::XS;

use version; our $VERSION = qv(1.0);

my $c = 'data/config.json';
open (my $C, '<', $c) or die "No conf at $c: $OS_ERROR\n";
my $len = (stat ($c)) [7];
my $json;
my $readlen = read ($C, $json, $len);

unless ($readlen) {
	close C;                                         ## no critic (InputOutput::RequireCheckedSyscalls)
	die "Unable to read $c: $OS_ERROR\n";
}

if ($readlen != $len) {
	close C;                                         ## no critic (InputOutput::RequireCheckedSyscalls)
	die "File $c is $len bytes on disk, but we read only $readlen bytes\n";
}

close C;                                             ## no critic (InputOutput::RequireCheckedSyscalls)
$c = JSON::XS->new->utf8->relaxed;
my $data = $c->decode ($json);

my $j = JSON::XS->new->pretty();
print $j->encode ($data);                            ## no critic (InputOutput::RequireCheckedSyscalls)

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
