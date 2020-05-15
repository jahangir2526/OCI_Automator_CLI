#!/usr/bin/env bash
# logger.sh <Name of the scripts> <Message>
cd `dirname ${BASH_SOURCE[0]}`
cd ..
V_DATE=`date '+%Y-%m-%d %H:%M:%S'`
V_FILE_NAME=`date '+%Y-%m'`
printf "$V_DATE\t$*\n" >> logs/$V_FILE_NAME
