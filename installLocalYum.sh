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

if [ $# -lt 1 ]
then
    echo "${error_flag}参数个数小于1个！"
    echo "${error_flag}需要传递1个参数，第一个参数：ISO文件绝对路径"
    exit 1
fi

if [ `whoami` != "root" ]
then
    echo "${error_flag}installLocalYum.sh must be excuted by root"
    exit 1
fi

isCentOS8
if [ $? != 0 ]
then
    echo "${error_flag}操作系统不是CentOS 8"
    exit 1
fi

if [ $(yum repolist | grep -E  "^LocalAppStream" | wc -l) -gt 0 ]
then
    echo "${error_flag}之前已经安装了LocalAppStream"
    exit 1
fi

if [ $(yum repolist | grep -E  "^LocalBaseOS" | wc -l) -gt 0 ]
then
    echo "${error_flag}之前已经安装了LocalBaseOS"
    exit 1
fi

iso_file=$1

if [ ! -f $iso_file ]
then
    echo "${error_flag}ISO文件[$iso_file]不存在"
    exit 1
fi

if [ $(echo "${iso_file^^}" | grep -E ".ISO$" | wc -l) == 0 ]
then
    echo "${error_flag}ISO文件[$iso_file]的后缀不是iso"
    exit 1
fi

now_time=$(date +%Y%m%d%H%M%S)
mkdir -p /mnt/my_iso_${now_time}

if [ ! -d /mnt/my_iso_${now_time}  ]
then
    echo "${error_flag}挂载目录[/mnt/my_iso_${now_time}]不存在"
    exit 1
fi

mount $iso_file /mnt/my_iso_${now_time}

if [ $(df -h | grep -E " /mnt/my_iso_${now_time}$"  | wc -l) == 0  ]
then
    echo "${error_flag}将[${iso_file}]挂载到[/mnt/my_iso_${now_time}]失败"
    exit 1
fi

echo ""
echo "将[${iso_file}]挂载到[/mnt/my_iso_${now_time}]成功"

if [ ! -d /mnt/my_iso_${now_time}/AppStream  ]
then
    echo "${error_flag}未找到目录[/mnt/my_iso_${now_time}/AppStream]，请确认iso文件"
    exit 1
fi

if [ ! -d /mnt/my_iso_${now_time}/BaseOS  ]
then
    echo "${error_flag}未找到目录[/mnt/my_iso_${now_time}/BaseOS]，请确认iso文件"
    exit 1
fi

cp -rf /etc/fstab /etc/fstab.${now_time}
echo "${iso_file} /mnt/my_iso_${now_time} iso9660 loop,defaults 0 0" >> /etc/fstab

cat <<EOF > /etc/yum.repos.d/local_yum_${now_time}.repo
[LocalBaseOS]
name=LocalBaseOS
baseurl=file:///mnt/my_iso_${now_time}/BaseOS
enabled=1
gpgcheck=0


[LocalAppStream]
name=LocalAppStream
baseurl=file:///mnt/my_iso_${now_time}/AppStream
enabled=1
gpgcheck=0
EOF

ok_flag=0
yum makecache --repo LocalAppStream
if [ $? != 0  ]
then
    echo "${error_flag}本地yum源[/mnt/my_iso_${now_time}/AppStream]加载失败"
    ok_flag=1
fi

yum makecache --repo LocalBaseOS
if [ $? != 0  ]
then
    echo "${error_flag}本地yum源[/mnt/my_iso_${now_time}/BaseOS]加载失败"
    ok_flag=1
fi

if [ $ok_flag == 1 ]
then
    exit 1
fi

echo ""
echo "本地yum源安装完毕!!!"
echo ""
exit 0

