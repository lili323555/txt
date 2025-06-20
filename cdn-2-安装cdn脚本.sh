#!/bin/bash

# Fikker CDN 安装目录和版本
FikkerInstallDir="/root"
FikkerNewVersion="fikkerd-3.7.6-linux-x86-64"



# 停止并禁用可能冲突的服务
echo "停止并禁用可能冲突的服务..."
service iptables stop 2> /dev/null
chkconfig iptables off 2> /dev/null
service httpd stop 2> /dev/null
service nginx stop 2> /dev/null
chkconfig httpd off 2> /dev/null
chkconfig nginx off 2> /dev/null
systemctl stop firewalld.service 2> /dev/null
systemctl disable firewalld.service 2> /dev/null
systemctl stop httpd.service 2> /dev/null
systemctl stop nginx.service 2> /dev/null
systemctl disable httpd.service 2> /dev/null
systemctl disable nginx.service 2> /dev/null

# 安装 wget 和 tar
echo "安装 wget 和 tar..."
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y wget tar
elif command -v yum &> /dev/null; then
    yum install -y wget tar
else
    echo "无法确定包管理器。"
    exit 1
fi

# 下载并安装 Fikker CDN
echo "下载并安装 Fikker CDN..."
cd $FikkerInstallDir || exit
rm -rf $FikkerNewVersion.tar.gz
wget -c --no-check-certificate http://38.54.17.87/fikkerd-3.7.6-linux-x86-64.tar.gz
if [ $? -ne 0 ]; then
    echo "下载失败，退出脚本。"
    exit 1
fi

tar zxf $FikkerNewVersion.tar.gz
rm -rf $FikkerNewVersion.tar.gz
cd $FikkerNewVersion || exit
chmod +x ./bin/fikkerd
./fikkerd.sh install
./fikkerd.sh start
if [ $? -ne 0 ]; then
    echo "Fikker 安装或启动失败，退出脚本。"
    exit 1
fi

# 配置防火墙
echo "配置防火墙..."
if command -v firewall-cmd &> /dev/null; then
    # 开放所有 TCP 和 UDP 端口
    firewall-cmd --zone=public --add-port=1-65535/tcp --permanent
    firewall-cmd --zone=public --add-port=1-65535/udp --permanent
    firewall-cmd --reload
    echo "已开放全部 TCP 和 UDP 端口。"
else
    echo "firewalld 未安装或不可用。"
fi

# 获取公网和内网 IP
pub_ip=$(curl -s ip.me)
loc_ip=$(hostname -I | awk '{print $1}')

echo "安装完成。请公网访问 http://$pub_ip:6780   初始密码为 123456"
echo "安装完成。请内网访问 http://$loc_ip:6780   初始密码为 123456"