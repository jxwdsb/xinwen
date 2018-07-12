#!/bin/bash
#¨Docker 快速搭建Aria2 不含UI¨
#¨v: 0.0.1¨ 
#¨By: xinwen¨ 
echo ¨docker: aria2¨
read -t 30 -n 1 -p "开始安装吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	read -s -p "设置连接端口[默认2346]:" port 
	if [[ ! -n "$port" ]]; then
		#echo -e "\033[31m 安装错误.未设置连接端口 \033[0m"
		#exit 0
		$port = 2346
		echo
	fi
	echo -e "\033[32m 开始安装Aria2 \033[0m"
	#开始执行
	wget -P /var/xinwen https://github.com/mayswind/AriaNg-DailyBuild/archive/master.zip
	7z x /var/xinwen/master.zip -r -o/var/xinwen/www/ariang -y
	rm /var/xinwen/master.zip
	docker pull pihizi/aria2
	docker run --name myaria2 -d -p $port:6800 -v /var/xinwen/aria2/log:/dev/log -v /var/xinwen/aria2/config:/etc/aria2 -v /var/xinwen/www/download:/data/aria2/download pihizi/aria2
	echo -e "\033[32m 安装完成 \033[0m"
	echo -e "\033[32m Aria2 下载目录:/var/xinwen/www/download \033[0m"
	echo -e "\033[32m Aria2 配置目录:/var/xinwen/aria2/config \033[0m"
	echo -e "\033[32m Aria2 日志目录:/var/xinwen/aria2/log \033[0m"
	echo -e "\033[32m Aria2 AriaNg:/var/xinwen/www/ariang【http://yourip/ariang】 \033[0m"
	exit 0
else
	echo 
	echo -e  "\033[31m 取消安装 \033[0m"
	exit 0
fi 