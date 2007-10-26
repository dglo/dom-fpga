#!/usr/bin/perl

# This script converts .mif files to .hex files... very simplistically
#

# normal build usage, from domapp directory:
# $ miftohex.pl < version_rom.mif > simulation/modelsim/version_rom.mif

$debug = 0;

# Read in the mif data
$data[0] = 0;
while (<STDIN>) {
	if ($_ =~ /^\s+([0-9]*)\s+:\s+([0-9]*);/) {
			$debug && print "$1 : $2\n";
			$data[$1] = $2;
	}
	if ($_ =~ /^\s*\[([0-9]*)\.\.([0-9]*)\]\s+:\s+([0-9]*);/) {
			$debug && print "$1..$2 : $3\n";
			for ($i=$1; $i<=$2; $i++) {
				$data[$i] = $3;
			}
	}
}


# Write the hex data
$address = 0;
for ($i=0; $i<=$#data; $i+=16) {
	$size = ($i+16<$#data) ? 15 : $#data - $i;
	$checksum = 0;
#    * The first character (:) indicates the start of a record.
	printf ":";
#    * The next two characters indicate the record length (10h in this case).
	printf "%.2x",$size+1;
	$checksum += $size+1;
#    * The next four characters give the load address (0080h in this case).
	printf "%.4x",$address;
	$checksum += (($address >> 8) & 0xff) + ($address & 0xff);
#    * The next two characters indicate the record type (see below).
	printf "00";
	$checksum += 0;
#    * Then we have the actual data.
	for ($j=0; $j<=$size; $j++) {
			printf "%.2x", $data[$i+$j];
			$checksum += $data[$i+$j] & 0xff;
	}
#    * The last two characters are a checksum (sum of all bytes + checksum = 00). 
	printf "%.2x\n", (0 - ($checksum & 0xff) & 0xff);

	$address += 16;
}

printf ":00000001FF";
#The last line of the file is special, and will always look like that above.



