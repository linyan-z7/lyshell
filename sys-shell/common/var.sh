#!/bin/bash
error_flag="==================>>>    "

declare -A sysctl_array=()
sysctl_array["net.ipv4.tcp_keepalive_time"]="30"
sysctl_array["net.ipv4.tcp_keepalive_intvl"]="5"
sysctl_array["net.ipv4.tcp_keepalive_probes"]="2"
sysctl_array["net.ipv4.tcp_fin_timeout"]="10"
sysctl_array["net.ipv4.ip_local_port_range"]="10000 62000"
sysctl_array["net.ipv4.tcp_max_tw_buckets"]="20000"
sysctl_array["net.ipv4.tcp_tw_recycle"]="1"
sysctl_array["net.ipv4.tcp_tw_reuse"]="1"
sysctl_array["net.core.somaxconn"]="10240"
sysctl_array["net.ipv4.tcp_syn_retries"]="1"
sysctl_array["net.ipv4.tcp_synack_retries"]="1"
sysctl_array["net.ipv4.tcp_timestamps"]="0"
sysctl_array["net.ipv4.tcp_max_syn_backlog"]="262144"
sysctl_array["net.ipv6.conf.all.disable_ipv6"]="1"
sysctl_array["net.ipv6.conf.default.disable_ipv6"]="1"
sysctl_array["net.ipv6.conf.lo.disable_ipv6"]="1"
sysctl_array["net.ipv6.conf.eth0.disable_ipv6"]="1"

function trim() {
    local str="$*"
    local length=${#str}
    local start=0
    local end=$(expr $length - 1)
    for ((i=0;i<$length;i++))
    do
        tmp="${str:$i:1}"
        #echo "[$tmp==$i]"
        if [ "$tmp" == " " ] 
        then
            start=$(expr $i + 1)
        elif [ "$tmp" == "	" ]
        then
            start=$(expr $i + 1)
        else
            break;
        fi
    done
    for ((i=$length-1;i>0;i--))
    do
        tmp="${str:$i:1}"
        #echo "[$tmp==$i]"
        if [ "$tmp" == " " ]
        then
            end=$(expr $i - 1)
        elif [ "$tmp" == "	" ]
        then
            end=$(expr $i - 1)
        else
            break;
        fi
    done

    if (( $end - $start + 1  > 0  &&  $start < $length  ))
    then
        echo "${str:$start:$(expr $end - $start + 1)}"
    else
        echo ""
    fi
 
}

function isCentOS8() {
    if [ ! -f /etc/redhat-release ]
    then
        echo "${error_flag}文件/etc/redhat-release不存在,不是CentOS系统"
        return 1
    fi
    file_content1="$(cat /etc/redhat-release)"
    file_content=${file_content1^^}
    if [ $(echo "$file_content" | grep "CENTOS " | wc -l) == 0 ] 
    then 
        echo "${error_flag}不是CentOS系统.[${file_content1}] "
        return 1
    fi
    if [ $(echo "$file_content" | grep " 8." | wc -l) == 0 ]
    then
        echo "${error_flag}不是CentOS系统.[${file_content1}] "
        return 1
    fi
    echo "操作系统是：[${file_content1}]"
    return 0
}

