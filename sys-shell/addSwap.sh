#!/bin/bash

my_pwd=$(pwd)
cd $(dirname $0)
bin_dir=$(pwd)
cd $bin_dir

source ./common/var.sh
./common/checkCommand.sh awk
if [ $? != 0 ]
then
    exit 1
fi

if [ $# -lt 2 ]
then
    echo "${error_flag}参数个数小于2个！"
    echo "${error_flag}需要传递2个参数，第一个参数：swap文件绝对路径，第二个参数：swap文件的大小，单位GB"
    exit 1
fi

if [ `whoami` != "root" ]
then
    echo "${error_flag}addSwap.sh must be excuted by root"
    exit 1
fi

swap_file=$1
swap_size=$2

if [[ ! $swap_file =~ ^/.* ]]
then
    echo "${error_flag}第一个参数必须是绝对路径，以/开头。当前是[$swap_file]"
    exit 
fi

if [ -e $swap_file  ]
then
    echo "${error_flag}文件[$swap_file]已存在"
    exit 1
fi

dd if=/dev/zero of=$swap_file bs=1024M count=$swap_size

file_size=$(ls -l $swap_file | awk '{print $5}')
file_size=$(expr $file_size / 1024 / 1024 / 1024 )

if [ $file_size -lt $swap_size ]
then
    echo "${error_flag}文件[$swap_file]大小为${file_size}GB，小于${swap_size}GB，请确认"
    exit 1
fi

mkswap $swap_file
swapon $swap_file

now_time=$(date +%Y%m%d%H%M%S)
cp -rf /etc/fstab /etc/fstab.${now_time}
echo "$swap_file swap swap defaults 0 0" >> /etc/fstab

mount -a
echo "当前内存情况如下："
free -m

exit 0

