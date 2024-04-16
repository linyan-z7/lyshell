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

flag_value=0
flag_file=0
soft_count=0
hard_count=0

now_value=$(ulimit -n)
if [ $now_value != 65535 ]
then
    flag_value=1
fi

file_line_count=$(cat /etc/security/limits.conf | wc -l )
echo "/etc/security/limits.conf line count [${file_line_count}]"

echo ""
echo ""


for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat /etc/security/limits.conf | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat /etc/security/limits.conf | awk -v line=$i 'NR==line{print}' | xargs)
    if [[ "$line_tmp" =~ ^#.* ]] 
    then
        continue
    elif [ $(echo "$line_tmp" | grep "soft nofile" | wc -l) == 1 ] 
    then 
        echo "$line"
        soft_count=1
        tmp_value=$(echo "$line_tmp" | awk '{print $4}')
        tmp_domain=$(echo "$line_tmp" | awk '{print $1}')
       
        if [ "$tmp_value" != "65535" -o "$tmp_domain" != "*" ]
        then
            flag_file=1
        fi

    elif [ $(echo "$line_tmp" | grep "hard nofile" | wc -l) == 1 ]
    then
        echo "$line"
        hard_count=1
        tmp_value=$(echo "$line_tmp" | awk '{print $4}')
        tmp_domain=$(echo "$line_tmp" | awk '{print $1}')
        if [ "$tmp_value" != "65535" -o "$tmp_domain" != "*" ]
        then
            flag_file=1
        fi

    fi
done

echo ""
echo ""


if [ $flag_value == 1 ]
then
    echo "${error_flag}open files = [${now_value}]"
else
    echo "open files value is ok"
fi

if [ $flag_file == 1 -o $hard_count == 0 -o $soft_count == 0 ]
then
    echo "${error_flag}/etc/security/limits.conf has error!!!"
else
    echo "/etc/security/limits.conf is ok"
fi



if [  $flag_file == 1 -o $hard_count == 0 -o $soft_count == 0 ]
then 
   exit 1
fi

exit 0
