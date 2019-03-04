#!/bin/bash
#¨Docker 快速搭建SSR代理¨
#¨v: 0.0.1¨
#¨By: xinwen¨
echo "docker: SSR"
read -t 30 -n 1 -p "开始安装吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	read -s -p "设置连接端口[默认8887]:" port 
	if [[ ! -n "$port" ]]; then
		port=8887
	fi
	echo
	read -s -p "设置连接密码:" passwd 
	if [[ ! -n "$passwd" ]]; then
		echo -e "\033[31m 安装错误.未设置连接密码 \033[0m"
		exit 0
	fi
	echo -e "\033[32m 开始安装 \033[0m"
	#开始执行
	wget -P /var/xinwen/ssr https://raw.githubusercontent.com/jxwdsb/xinwen/master/shadowsocks.json 
	sed -i "s/xinwen/$passwd/g" `grep xinwen -rl /var/xinwen/ssr`
	chmod -R 755 /var/xinwen/ssr
	docker pull 4kerccc/shadowsocksr
	docker run --name myssr -itd -p $port:80 -v /var/xinwen/ssr/shadowsocks.json:/etc/shadowsocks.json 4kerccc/shadowsocksr
	ip=`ifconfig eth0 | grep 'inet ' | sed s/^.*inet//g | sed s/netmask.*$//g | sed 's/ //g'`
	echo -e "\033[32m 安装完成 \033[0m"
	echo -e "\033[32m 服务器IP地址: "$ip" \033[0m"
	echo -e "\033[32m 远程端口: $port \033[0m"
	echo -e "\033[32m 密码: "$passwd" \033[0m"
	echo -e "\033[32m 认证协议: auth_sha1_v4 \033[0m"
	echo -e "\033[32m 混淆方式: http_simple \033[0m"
	echo -e "\033[32m 加密方法: chacha20 \033[0m"
	echo -e "\033[32m 配置文件 /var/xinwen/ssr/shadowsocks.json \033[0m"
	echo -e "\033[32m 配置文件修改后执行 docker restart myssr \033[0m"
	cd /root
	exit 0
else
	echo 
	echo -e  "\033[31m 取消安装 \033[0m"
	exit 0
fi 