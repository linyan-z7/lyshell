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

flag_value="0"
flag_file="0"

now_value="$(getenforce)"
now_value="${now_value,,}"
if [ "$now_value" != "disabled" ]
then
    flag_value="1"
fi

tmp_file_path=/etc/selinux/config
file_line_count=$(cat $tmp_file_path | wc -l )
echo "$tmp_file_path line count [${file_line_count}]"

echo ""
echo ""


for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}' | xargs)
    line_tmp="${line_tmp^^}"
    if [[ "$line_tmp" =~ ^#.* ]] 
    then
        continue
    elif [ $(echo "$line_tmp" | grep "SELINUX" | wc -l) == 1 ] 
    then 
        tmp_name="$(echo "$line_tmp" | awk -F= '{print $1}' )"
        tmp_value="$(echo "$line_tmp" | awk -F= '{print $2}' )"
        tmp_name="$(trim $tmp_name)"
        tmp_value="$(trim $tmp_value)"        
       
	echo "$line"
        if [ "$tmp_name" == "SELINUX" -a "$tmp_value" != "DISABLED" ]
        then
            flag_file="$tmp_value"
        fi
    else
        continue
    fi
done

echo ""
echo ""

if [ "$flag_value" == "1" ]
then
    echo "${error_flag}selinux = [${now_value}]"
else
    echo "selinux = [${now_value}]"
fi

if [ "$flag_file" != "0" ]
then
    echo "${error_flag}selinux file [/etc/selinux/config] value [$flag_file]"
else
    echo "selinux file [/etc/selinux/config] value [DISABLED]"
fi


if [  "$flag_file" != "0" ]
then 
   exit 1
fi

exit 0
