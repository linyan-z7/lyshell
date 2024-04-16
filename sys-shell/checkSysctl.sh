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


declare -A sysctl_flag1=()
for key in ${!sysctl_array[@]}
do
    sysctl_flag1[$key]="0"
done


declare -A sysctl_flag2=()
for key in ${!sysctl_array[@]}
do
    sysctl_flag2[$key]="0"
done


now_time=$(date +%Y%m%d%H%M%S)
tmp_file_path=/tmp/sysctl.${now_time}
sysctl -a | grep "net.ipv" > $tmp_file_path

file_line_count=$(cat $tmp_file_path | wc -l )
echo "sysctl -a result count [${file_line_count}]"

for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}' | xargs)
    
    tmp_name=$(echo "$line_tmp" | awk -F= '{print $1}' )
    tmp_value=$(echo "$line_tmp" | awk -F= '{print $2}' )
    tmp_name=$(trim $tmp_name)
    tmp_value=$(trim $tmp_value)

 
    tmp_value0="${sysctl_array[$tmp_name]}"
    if [ "$tmp_value0" != "" ]
    then
        if [ "$tmp_value0" != "$tmp_value" ]
        then
            sysctl_flag1[$tmp_name]="[$tmp_value0]   [$tmp_value]"
	else
	    sysctl_flag1[$tmp_name]="1"
        fi
    fi  

done

rm -rf $tmp_file_path

echo ""
echo ""

tmp_file_path=/etc/sysctl.conf
file_line_count=$(cat $tmp_file_path | wc -l )
echo "/etc/sysctl.conf line count [${file_line_count}]"

for ((i=1;i<=$file_line_count;i++))
do
    line=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}')
    line_tmp=$(cat $tmp_file_path | awk -v line=$i 'NR==line{print}' | xargs)
    
    tmp_name=$(echo "$line_tmp" | awk -F= '{print $1}' )
    tmp_value=$(echo "$line_tmp" | awk -F= '{print $2}' )
    tmp_name=$(trim $tmp_name)
    tmp_value=$(trim $tmp_value)

 
    tmp_value0="${sysctl_array[$tmp_name]}"
    if [ "$tmp_value0" != "" ]
    then
        if [ "$tmp_value0" != "$tmp_value" ]
        then
            sysctl_flag2[$tmp_name]="[$tmp_value0]   [$tmp_value]"
	else
	    sysctl_flag2[$tmp_name]="1"
        fi
    fi  

done



echo ""
echo ""

tmp_result1=0
tmp_result2=0
for key in ${!sysctl_array[@]}
do
    tmp_v=${sysctl_flag1[$key]}
    if [ "$tmp_v" == "0" ]
    then
        echo "$error_flag[VALUE]$key not exist"
        tmp_result1=1
    elif [ "$tmp_v" == "1" ]
    then
        echo "[VALUE]$key is OK"
    else
        echo "$error_flag[VALUE]$key$tmp_v"
        tmp_result1=1
    fi
    tmp_v=${sysctl_flag2[$key]}
    if [ "$tmp_v" == "0" ]
    then
        echo "$error_flag[FILE]$key not exist"
        tmp_result2=1
    elif [ "$tmp_v" == "1" ]
    then        
        echo "[FILE]$key is OK"
    else
        echo "$error_flag[FILE]$key$tmp_v"
        tmp_result2=1
    fi
    echo ""
done

echo ""
echo ""

if [ $tmp_result1 != 0 ]
then
    echo "${error_flag} current system value has error!!!"
fi

if [ $tmp_result2 != 0 ]
then
    echo "${error_flag} /etc/sysctl.conf has error!!!"
fi
echo ""

if [  $tmp_result2 != 0  ]
then
    exit 1
fi

exit 0
