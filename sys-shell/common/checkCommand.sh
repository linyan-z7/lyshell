#!/bin/bash

my_pwd=$(pwd)
cd $(dirname $0)
bin_dir=$(pwd)
cd $bin_dir


source ./var.sh

if [ "$1" == "" ]
then
    echo "${error_flag}checkCommand.sh must have parameter !!!"
    exit 1
fi

which $1
if [ $? != 0 ]
then
    echo "${error_flag}$1 no install !!!"
    exit 1
fi

exit 0
