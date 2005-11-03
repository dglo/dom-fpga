#!/bin/bash

#
# script files location...
#
sdir=.

#
# convert a fpga_type number to a string (nm)
#
function fpga_type () { grep "^${1} " tdata.txt | cut -d ' ' -f 2; }

# layout of file (everything is a 16bit word):
#   fpga_type (from current dir fpga_type file...)
#   build_num0 (from current dir build_num file...)
#   build_num1 (from current dir build_num file...)
#   versions (read from sdata.txt):
#

echo "#ifndef MKHDR_AUTOGENERATED_HEADER"
echo "#define MKHDR_AUTOGENERATED_HEADER"
echo " "
echo "/* autogenerated .h file from mkhdr.sh */"
echo " "
echo "/* communications version */"
echo "#define FPGA_VERSIONS_DOM_COMM_INDEX 100"
taf=${sdir}/../common/comDPM/test_and_tresholds.tdf
dcrev=`awk '$2 ~ /^DCFREV$/ { print $4; }' ${taf} | \
        sed 's/^00*//1' | sed 's/;.*//1'`
echo "#define FPGA_VERSIONS_DOM_COMM_VERSION ${dcrev}"
echo " "
echo "/* map module name to index, (columns of expected_versions) */"
vals=`cut -d ' ' -f 1 ${sdir}/sdata.txt`
for f in $vals; do
    nm=`grep ^${f} ${sdir}/sdata.txt | cut -d ' ' -f 2 \
	| tr [:lower:] [:upper:]`
    printf "#define FPGA_VERSIONS_%s %d\n" $nm $f
done

last_row=`awk 'BEGIN{max=0;} { if ($1>max) max=$1 } END{print max;}' \
    ${sdir}/tdata.txt`
last_col=`awk 'BEGIN{max=0;} { if ($1>max) max=$1 } END{print max;}' \
    ${sdir}/sdata.txt`

echo " "
echo "/* map fpga type to index, (rows of expected_versions) */"
types=`cut -d ' ' -f 1 ${sdir}/tdata.txt`
for t in $types; do
    nm=`fpga_type $t | tr [:lower:] [:upper:]`
    printf "#define FPGA_VERSIONS_TYPE_%s %d\n" ${nm} $t
done

echo " "
echo "/* expected (compiled in) version numbers */"
printf "static short expected_versions[%d][%d] = {\n" `expr ${last_row} + 1` \
    `expr ${last_col} + 1`

for (( i=0 ; i<=${last_row}; i++ )) ; do
    #
    # find row in types...
    #
    printf "  { ${i}, /* %s */\n" `fpga_type $i`
    echo "    0, 0, /* skip build number fields */"
    t=`grep "^${i} " ${sdir}/tdata.txt | cut -d ' ' -f 2`
    if grep "^${t} " ${sdir}/ddata.txt >& /dev/null; then
	# get directory...
        fdir=`grep "^${t} " ${sdir}/ddata.txt | awk '{ print $2; }'`
	if [[ ! -d ${fdir} ]]; then
            echo "`basename $0`: ${fdir} of type $t is not a directory"
            exit 1
        fi
	for f in $vals; do
	    nm=`grep ^${f} ${sdir}/sdata.txt | cut -d ' ' -f 2`
	    nd=`echo ${fdir} | tr -c -d '/' | wc -c | awk '{ print $1; }'`
            if (( $nd == 2 )); then
                vcd="../.."
            elif (( $nd == 1 )); then
                vcd=".."
            else
                echo "`basename $0`: $fdir invalid: nd=$nd, must be 1 or 2"
                exit 1
            fi
  	    ver=`(cd ${fdir}; ${vcd}/scripts/getver.sh ${nm}.ver)`
            printf "    %d, /* %s */\n" $ver $nm
	done
    else
	for f in $vals; do
	    nm=`grep ^${f} ${sdir}/sdata.txt | cut -d ' ' -f 2`
	    printf "    0, /* %s */\n" $nm
	done
    fi
    echo "  },"
done
echo "};"
echo " "
echo "#endif"
