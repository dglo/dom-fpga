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
#   versions:
#      1: com_fifo
#      2: com_dp
#      3: daq (atwd, fadc)
#      4: pulsers
#      5: discriminator_rate
#      6: local_coinc
#      7: flasher_board
#      8: trigger
#      9: local_clock
#     10: supernova
#     11: unassigned
#     12: unassigned
#     13: unassigned
#     14: unassigned
#     15: unassigned
#     16: unassigned
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
echo "        0 :" `/bin/bash ${sdir}/getfpga.sh`

bn=`${sdir}/getbld.sh`

echo "        1 :" `expr ${bn} % 65535`
echo "        2 :" `expr ${bn} / 65535`
echo "        3 :" `/bin/bash ${sdir}/getver.sh com_fifo.ver`
echo "        4 :" `/bin/bash ${sdir}/getver.sh com_dp.ver`
echo "        5 :" `/bin/bash ${sdir}/getver.sh daq.ver`
echo "        6 :" `/bin/bash ${sdir}/getver.sh pulsers.ver`
echo "        7 :" `/bin/bash ${sdir}/getver.sh discriminator_rate.ver`
echo "        8 :" `/bin/bash ${sdir}/getver.sh local_coinc.ver`
echo "        9 :" `/bin/bash ${sdir}/getver.sh flash_board.ver`
echo "       10 :" `/bin/bash ${sdir}/getver.sh trigger.ver`
echo "       11 :" `/bin/bash ${sdir}/getver.sh local_clock.ver`
echo "       12 :" `/bin/bash ${sdir}/getver.sh supernova.ver`
echo "[13..127] : 0"

