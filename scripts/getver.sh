#!/bin/bash 

#
# get current version number
#
fname=$1

if [[ ! -f ./${fname} ]] ; then
    if [[ ! -f ../common/${fname} ]] ; then
        if [[ ! -f ../../common/${fname} ]]; then
          echo 0 > ../../common/${fname}
          cat ../../common/${fname} | tr -d '\r'
        else
          cat ../../common/${fname} | tr -d '\r'
        fi
    else
       cat ../common/${fname} | tr -d '\r'
    fi
else
    cat ${fname} | tr -d '\r'
fi




