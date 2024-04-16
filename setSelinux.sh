#!/bin/bash

my_pwd=$(pwd)
cd $(dirname $0)
bin_dir=$(pwd)
cd $bin_dir

source ./common/var.sh
./checkSelinux.sh
if [ $? == 0 ]
then
    echo ""
    echo ""
    echo "Current config file [/etc/selinux/config] is right ! Don't need set "
    exit 0
fi

if [ `whoami` != "root" ]
then
    echo "${error_flag}setSelinux.sh must be excuted by root"
    exit 1
fi

now_time=$(date +%Y%m%d%H%M%S)
cp -rf /etc/selinux/config /etc/selinux/config.$now_time

file_line_count=$(cat /etc/selinux/config.$now_time | wc -l )
echo "/etc/selinux/config line count [${file_line_count}]"

rm -rf /etc/selinux/config.$now_time.tmp

tmp_file_path=/etc/selinux/config.$now_time
have_config="0"

for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}' | xargs)
    line_tmp="${line_tmp^^}"
    if [[ "$line_tmp" =~ ^#.* ]] 
    then
        echo "$line" >> /etc/selinux/config.$now_time.tmp
    elif [ $(echo "$line_tmp" | grep "SELINUX" | wc -l) == 1 ] 
    then 
        tmp_name="$(echo "$line_tmp" | awk -F= '{print $1}' )"
        tmp_value="$(echo "$line_tmp" | awk -F= '{print $2}' )"
        tmp_name="$(trim $tmp_name)"
        tmp_value="$(trim $tmp_value)"        
       
        if [ "$tmp_name" == "SELINUX" ]
        then	    
	    echo "SELINUX=disabled" >> /etc/selinux/config.$now_time.tmp
	    have_config="1"
	else
	    echo "$line" >> /etc/selinux/config.$now_time.tmp
        fi
    else
        echo "$line" >> /etc/selinux/config.$now_time.tmp
    fi
done

if [ "$have_config" == "0" ]
then
    echo "SELINUX=disabled" >> /etc/selinux/config.$now_time.tmp
fi

chmod 644 /etc/selinux/config.$now_time.tmp
rm -rf /etc/selinux/config
mv /etc/selinux/config.$now_time.tmp /etc/selinux/config


echo ""
echo ""
echo ""

cat /etc/selinux/config
echo ""
echo ""
ls -l /etc/selinux/config
echo ""

exit 0
