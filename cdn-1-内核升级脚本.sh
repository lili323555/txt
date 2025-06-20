#!/bin/bash

# 备份原始的CentOS源文件
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

# 下载阿里云的CentOS源文件
curl -s http://mirrors.aliyun.com/repo/Centos-7.repo > /etc/yum.repos.d/CentOS-Base.repo

# 清除缓存
yum clean all

# 安装 wget（如果系统中没有 wget 的话）
yum install -y wget

# 下载并安装指定版本的 kernel-lt
wget https://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-5.4.203-1.el7.elrepo.x86_64.rpm
yum localinstall -y kernel-lt-5.4.203-1.el7.elrepo.x86_64.rpm

# 更新GRUB配置
grub2-mkconfig -o /boot/grub2/grub.cfg

# 查看可用的内核选项（可选步骤）
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg

# 设置默认启动项为新安装的内核
grub2-set-default 'CentOS Linux (5.4.203-1.el7.elrepo.x86_64) 7 (Core)'

# 重启系统使更改生效
echo "系统将在10秒钟后重启，请保存所有工作。"
sleep 10
reboot