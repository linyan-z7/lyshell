#!/bin/bash

my_pwd=$(pwd)
cd $(dirname $0)
bin_dir=$(pwd)
cd $bin_dir

source ./common/var.sh
./checkLimits.sh
if [ $? == 0 ]
then
    echo ""
    echo ""
    echo "Current config file [/etc/security/limits.conf] is right ! Don't need set "
    exit 0
fi

if [ `whoami` != "root" ]
then
    echo "${error_flag}setLimits.sh must be excuted by root"
    exit 1
fi

now_time=$(date +%Y%m%d%H%M%S)
cp -rf /etc/security/limits.conf /etc/security/limits.conf.$now_time

file_line_count=$(cat /etc/security/limits.conf.$now_time | wc -l )
echo "/etc/security/limits.conf line count [${file_line_count}]"

rm -rf /etc/security/limits.conf.$now_time.tmp


for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat /etc/security/limits.conf.$now_time | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat /etc/security/limits.conf.$now_time | awk -v line=$i 'NR==line{print}' | xargs)
    if [[ "$line_tmp" =~ ^#.* ]] 
    then
        echo "$line" >> /etc/security/limits.conf.$now_time.tmp
    elif [[ $(echo "$line_tmp" | grep "soft nofile" | wc -l) == 1 ]] 
    then 
        echo "#$line" >> /etc/security/limits.conf.$now_time.tmp
    elif [[ $(echo "$line_tmp" | grep "hard nofile" | wc -l) == 1 ]]
    then
        echo "#$line" >> /etc/security/limits.conf.$now_time.tmp
    fi
done

echo "* soft nofile 65535" >> /etc/security/limits.conf.$now_time.tmp
echo "* hard nofile 65535" >> /etc/security/limits.conf.$now_time.tmp

chmod 644 /etc/security/limits.conf.$now_time.tmp
rm -rf /etc/security/limits.conf
mv /etc/security/limits.conf.$now_time.tmp /etc/security/limits.conf


echo ""
echo ""
echo ""

cat /etc/security/limits.conf
echo ""
echo ""
ls -l /etc/security/limits.conf
echo ""

exit 0
