#!/bin/bash 

#
# get current fpga type...
#
sdir=../../scripts

if [[ ! -d ${sdir} ]]; then
	sdir=../scripts

	if [[ ! -d ${sdir} ]]; then
		echo "getfpga.sh: can not find scripts"
		exit 1
	fi
fi

#
# get last two components of cwd...
#
wd1=`pwd | awk -v FS='/' '{ print $(NF-1) }'`
wd2=`pwd | awk -v FS='/' '{ print $NF }' | sed 's/^Com.*/Com/1' | \
	sed 's/^NoCom.*/NoCom/1'`

if [[ ${wd1} == "dom-fpga" ]]; then
	type=${wd2}
else
	if [[ ${#wd2} > 0 ]]; then
    		type=${wd1}_${wd2}
	else
    		type=${wd1}
	fi
fi

if nm=`grep " ${type}\$" ${sdir}/tdata.txt`; then
    echo $nm | cut -d ' ' -f 1
else
    echo 0
fi

