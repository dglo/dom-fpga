#!/bin/bash

#
# script files location...
#
sdir=../../scripts

#
# make a new build number...
#
${sdir}/newbld.sh

#
# layout of file (everything is a 16bit word):
#   fpga_type (from current dir fpga_type file...)
#   build_num0 (from current dir build_num file...)
#   build_num1 (from current dir build_num file...)
#   versions (read from sdata.txt):
#

echo "-- mkmif.sh generated .mif file"
echo " "
echo "WIDTH=16;"
echo "DEPTH=128;"
echo " "
echo "ADDRESS_RADIX=UNS;"
echo "DATA_RADIX=UNS;"
echo " "
echo "CONTENT BEGIN"
echo "        0 :" `/bin/bash ${sdir}/getfpga.sh`";"

bn=`${sdir}/getbld.sh`

echo "        1 :" `expr ${bn} % 65535`";"
echo "        2 :" `expr ${bn} / 65535`";"
vals=`cut -d ' ' -f 1 ${sdir}/sdata.txt`
last=0
for f in $vals; do
    nm=`grep ^${f} ${sdir}/sdata.txt | cut -d ' ' -f 2`
    printf "%9d : %d;\n" $f `${sdir}/getver.sh ${nm}.ver` 
    last=${f}
done

last=`expr ${last} + 1`
echo "[${last}..127] : 0;"

echo "END;"

