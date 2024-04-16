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

if [ $# -lt 2 ]
then
    echo "${error_flag}参数个数小于2个！"
    echo "${error_flag}需要传递2个参数，第一个参数：在那个用户下安装JDK。第二个参数：JDK文件的绝对路径"
    exit 1
fi

if [ `whoami` != "root" ]
then
    echo "${error_flag}installJDK.sh must be excuted by root"
    exit 1
fi

install_user=$1
jdk_file=$2

echo ""
echo "将在用户[$install_user]下安装JDK[$jdk_file]"

id $install_user
if [ $? -ne 0 ]
then
    echo "${error_flag}用户[$install_user]不存在"
    exit 1
fi

user_dir=$(cat /etc/passwd | grep "^$install_user" |  awk -F: '{print $6}')
echo $user_dir
if [ ! -d $user_dir ]
then
    echo "${error_flag}用户[$install_user]的主目录[$user_dir]不存在"
    exit 1
fi

su - $install_user -c "which java"
if [ $? -eq 0 ]
then
    echo "${error_flag}用户[$install_user]已经安装JDK"
    exit 1
fi

if [ ! -f $jdk_file ]
then
    echo "${error_flag}JDK安装文件[$jdk_file]不存在"
    exit 1
fi

now_time=$(date +%Y%m%d%H%M%S)
mkdir /tmp/installJDK-${now_time}
rm -rf /tmp/installJDK-${now_time}/*

tar -xzvf $jdk_file -C /tmp/installJDK-${now_time} > /dev/null
if [ $? -ne 0 ]
then
    echo "${error_flag}JDK安装文件[$jdk_file]解压失败，请确认文件格式正确"
    rm -rf /tmp/installJDK-${now_time}
    exit 1
fi
echo "JDK安装文件[$jdk_file]解压完毕"

jdk_name=""
for name in $(ls /tmp/installJDK-${now_time})
do
    tmp=${name^^}
    if [[ $tmp =~ ^JDK.* ]]
    then
        jdk_name=$name
        break
    fi
done

if [ "$jdk_name" == "" ]
then
    echo "${error_flag}未找到JDK目录"
    rm -rf /tmp/installJDK-${now_time}
    exit 1
fi

echo ""
echo "安装的JDK版本是[$jdk_name]" 


if [ -e $user_dir/$jdk_name ]
then
    echo "${error_flag}安装目录[$user_dir/$jdk_name]已经存在"
    rm -rf /tmp/installJDK-${now_time}
    exit 1
fi

su - $install_user -c "cp -rf /tmp/installJDK-${now_time}/$jdk_name $user_dir/"
if [ $? -ne 0  ]
then
    echo "${error_flag}拷贝[$user_dir/$jdk_name]到[$user_dir]失败"
    rm -rf /tmp/installJDK-${now_time}
    exit 1
fi
echo "拷贝[$user_dir/$jdk_name]到[$user_dir]完毕"

su - $install_user -c "echo \"JAVA_HOME=~/$jdk_name\" >> ~/.bash_profile"
su - $install_user -c "echo 'PATH=\$JAVA_HOME/bin:\$PATH' >> ~/.bash_profile"
su - $install_user -c "echo 'export JAVA_HOME' >> ~/.bash_profile"
su - $install_user -c "echo 'export PATH' >> ~/.bash_profile"

su - $install_user -c "which java"
if [ $? -ne 0 ]
then
    echo "${error_flag}配置后用户[$install_user]无法找到java命令。请人工确认"
    rm -rf /tmp/installJDK-${now_time}
    exit 1
fi
echo ""
echo "用户[$install_user]安装JDK成功！"
echo ""


rm -rf /tmp/installJDK-${now_time}

