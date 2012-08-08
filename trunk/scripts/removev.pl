#!/usr/bin/perl

# This script removes all .v files that have an identical .vhd ending.  It's
# useful during Quartus builds.  Right now, .vhd and .v files of quartus
# megafunctions exist in the CVS directories.  By using this script before
# compilation, you can be sure that your quartus builds are using .vhd
# functions.

$Debug = 0;
$DELETE = 0;

if ($ARGV[0] =~ /^-f/) {
	$DELETE = 1;
} else {
	print "Will NOT delete files unless you give the \"-f\" flag.\n";
}

# find all .vhd and .v filenames
print "Getting lists.\n";
open OUTPUT, "ls -1|";
while (<OUTPUT>) {
	chomp $_;
	if ($_ =~ /(.*)\.v$/) {
		$VList{$1} = 1;
		$Debug && print "Found .v: $_\n";
	}
	if ($_ =~ /(.*)\.vhd$/) {
		$VHDList{$1} = 1;
		$Debug && print "Found .vhd: $_\n";
	}
}
close OUTPUT;

# find all .vhd file stems in the .v list
print "Matching up .vhd files.\n";
foreach (keys %VHDList) {
	if (exists $VList{$_}) {
		$RMList{$_} = 1;
		$Debug && print "Found matching .vhd: $_\n";
	}
}

@keys = keys %RMList;
if ($#keys < 0) {
		print "No duplicate filenames found.\n";
} else {
		# Remove the files
		print "Removing files.\n";
		foreach (keys %RMList) {
			if ($DELETE == 1) {
				system "rm $_.v";
				print "Deleting file: ";
			}	
			print "$_.v\n";
		}
}




