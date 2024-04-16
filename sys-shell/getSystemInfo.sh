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

echo ""
echo "系统启动时间："
uptime -s
echo ""

if [ -f /etc/redhat-release ]
then
    echo ""
    echo "操作系统版本："
    cat /etc/redhat-release
    echo ""
fi

echo ""
echo "CPU核数："
lscpu | grep '^CPU(s):' 
echo ""


echo ""
echo "内存大小："
lsmem | grep 'Total online memory'
echo ""

echo ""
echo "磁盘信息："
fdisk -l | grep dev | grep Disk
echo ""

echo ""
echo "磁盘分区情况："
echo "Device     Boot Start        End    Sectors  Size Id Type"
fdisk -l | grep /dev | grep -v Disk
echo ""

echo ""
echo "网卡信息："
ifconfig -a | grep -e "flags" -e "inet"
echo ""
