#!/bin/bash

my_pwd=$(pwd)
cd $(dirname $0)
bin_dir=$(pwd)
cd $bin_dir

source ./common/var.sh
./common/checkCommand.sh wget
if [ $? != 0 ]
then
    echo "请先安装wget"
    exit 1
fi

now_time=$(date +%Y%m%d%H%M%S)
wget --post-data "" https://app.ipdatacloud.com/v1/ip_self_search -O /tmp/ip-${now_time}.txt  

echo ""
echo ""
cat /tmp/ip-${now_time}.txt
echo ""
echo ""
echo ""
echo "本机的公网IP是(空表示获取失败)："
expr "$(cat /tmp/ip-${now_time}.txt)" : '.*\"ip\"\:\"\([0-9.]*\)\"' 
echo ""
echo ""
exit 0
