#!/bin/bash 

#
# get current version number
#
set fname=$1

if [[ ! -f ./${fname} ]] ; then
    if [[ ! -f ../common/${fname} ]] ; then
        if [[ ! -f ../../common/${fname} ]]; then
          echo 0 > ../../common/${fname}
          cat ../../common/${fname}
        else
          cat ../../common/${fname}
        fi
    else
       cat ../common/${fname}
    fi
else
    cat ${fname}
fi




