#!/bin/bash 

#
# autoincrementing build number...
#
if [[ `pwd | awk -vFS="\/" '{ print $(NF-1); }'` == "dom-fpga" ]]; then
    bnf=../common/build_num
else
    bnf=../../common/build_num
fi

#
# create file if it doesn't exist yet...
#
if [[ ! -f $bnf ]] ; then echo 0 > ${bnf}; fi

bn=`cat ${bnf}`

#
# now increment it...
#
nbn=`expr $bn + 1`
echo $nbn > $bnf

echo $bn

