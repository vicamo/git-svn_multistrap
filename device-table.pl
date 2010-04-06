#!/usr/bin/perl

# Copyright (C) 2010  Neil Williams <codehelp@debian.org>
#
# This package is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use File::Basename;
use POSIX qw(locale_h);
use Locale::gettext;
use vars qw/ @list @seq $file $dir $line @cmd $i $dry
 $msg $progname $ourversion $fakeroot /;

@list =();
@seq = ();

setlocale(LC_MESSAGES, "");
textdomain("multistrap");
$progname = basename($0);
$ourversion = &our_version();
# default file from mtd-utils.
$file = "/usr/share/multistrap/device-table.txt";
$dir = `pwd`;
chomp ($dir);
$dir .= "/tmp/";
$fakeroot = "fakeroot";

while( @ARGV ) {
	$_= shift( @ARGV );
	last if m/^--$/;
	if (!/^-/) {
		unshift(@ARGV,$_);
		last;
	}
	elsif (/^(-\?|-h|--help|--version)$/) {
	&usageversion();
		exit( 0 );
	}
	elsif (/^(-f|--file)$/) {
		$file = shift(@ARGV);
	}
	elsif (/^(-d|--dir)$/) {
		$dir = shift(@ARGV);
	}
	elsif (/^(-n|--dry-run)$/) {
		$dry++;
	}
	elsif (/^(--no-fakeroot)$/) {
		$fakeroot="";
	}
	else {
		die "$progname: "._g("Unknown option")." $_.\n";
	}
}

$msg = sprintf (_g("Need a configuration file - use %s -f\n"), $progname);
die ($msg)
	if (not -f $file);

my $ret = 0;
$ret = mkdir ("$dir") if (not -d "$dir");
$dir = `realpath $dir`;
chomp ($dir);
$dir .= ($dir =~ m:/$:) ? '' : "/";

printf (_g("%s %s using %s\n"), $progname, $ourversion, $file);
open (TABLE, "<", $file) or die ("$file: $!\n");
@list=<TABLE>;
close (TABLE);
foreach $line (@list)
{
	chomp ($line);
	next if ($line =~ /^#/);
	next if ($line =~ /^$/);
	@cmd = split (/\t/, $line);
	next if ($cmd[2] eq "d");
	if ($cmd[9] =~ /-/)
	{
		push @seq, "mknod -m $cmd[2] $cmd[0] $cmd[1] $cmd[5] $cmd[6]";
	}
	else
	{
		for ($i = 0; $i < $cmd[9]; $i += $cmd[8])
		{
			push @seq, "mknod -m $cmd[2] $cmd[0]$i $cmd[1] $cmd[5] $cmd[6]";
		}
	}
}
if (defined $dry)
{
	print join ("\n", @seq);
	print "\n";
}
else
{
	chdir ("$dir");
	system ("pwd");
	foreach my $node (@seq)
	{
		system ("$fakeroot $node");
	}
}

sub our_version {
	my $query = `dpkg-query -W -f='\${Version}' multistrap`;
	(defined $query) ? return $query : return "0.0.9";
}

sub usageversion {
	printf STDERR (_g("
%s version %s

 %s [-d DIR] [-f FILE]
 %s -?|-h|--help|--version
"), $progname, $ourversion, $progname, $progname);
}

sub _g {
    return gettext(shift);
}

=pod

=head1 Name

device-table.pl - parses simple device tables and passes to mknod

=head1 Synopsis

 device-table.pl [-d DIR] [-f FILE]
 device-table.pl -?|-h|--help|--version

=head1 Options

By default, device-table.pl writes out the device nodes in the current
working directory. Use the directory option to write out elsewhere.

multistrap contains a default device-table file, use the file option
to override the default /usr/share/multistrap/device-table.txt

Use the dry-run option to see the commands that would be run.

Device nodes needs fakeroot or another way to use root access. If
device-table.pl is already being run under fakeroot or equivalent,
use the no-fakeroot option to drop the internal fakeroot usage.

=cut
