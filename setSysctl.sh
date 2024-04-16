#!/bin/bash

my_pwd=$(pwd)
cd $(dirname $0)
bin_dir=$(pwd)
cd $bin_dir

source ./common/var.sh
./checkSysctl.sh
if [ $? == 0 ]
then
    echo ""
    echo ""
    echo "Current config file[/etc/sysctl.conf] is right ! Don't need set "
    exit 0
fi

if [ `whoami` != "root" ]
then
    echo "${error_flag}setSysctl.sh must be excuted by root"
    exit 1
fi

declare -A sysctl_flag1=()
for key in ${!sysctl_array[@]}
do
    sysctl_flag1[$key]="0"
done

now_time=$(date +%Y%m%d%H%M%S)
cp -rf /etc/sysctl.conf /etc/sysctl.conf.$now_time

file_line_count=$(cat /etc/sysctl.conf.$now_time | wc -l )
echo "/etc/sysctl.conf line count [${file_line_count}]"

rm -rf /etc/sysctl.conf.$now_time.tmp


for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat /etc/sysctl.conf.$now_time | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat /etc/sysctl.conf.$now_time | awk -v line=$i 'NR==line{print}' | xargs)

    tmp_name=$(echo "$line_tmp" | awk -F= '{print $1}' )
    tmp_value=$(echo "$line_tmp" | awk -F= '{print $2}' )
    tmp_name=$(trim $tmp_name)
    tmp_value=$(trim $tmp_value)
 
    tmp_value0="${sysctl_array[$tmp_name]}"
    if [ "$tmp_value0" != "" ]
    then
        if [ "$tmp_value0" != "$tmp_value" ]
        then
	    echo "$tmp_name = $tmp_value0" >> /etc/sysctl.conf.$now_time.tmp
	else
	    sysctl_flag1[$tmp_name]="1"
	    echo "$line" >> /etc/sysctl.conf.$now_time.tmp
        fi
    else
        echo "$line" >> /etc/sysctl.conf.$now_time.tmp
    fi 
done

for key in ${!sysctl_array[@]}
do
    tmp_v=${sysctl_flag1[$key]}
    tmp_val="${sysctl_array[$key]}"
    if [ "$tmp_v" == "0" ]
    then
        echo "$key = $tmp_val" >> /etc/sysctl.conf.$now_time.tmp
    fi
done

chmod 644 /etc/sysctl.conf.$now_time.tmp
rm -rf /etc/sysctl.conf
mv /etc/sysctl.conf.$now_time.tmp /etc/sysctl.conf


echo ""
echo ""
echo ""

cat /etc/sysctl.conf
echo ""
echo ""
ls -l /etc/sysctl.conf
echo ""

exit 0
