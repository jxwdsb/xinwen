#!/bin/bash
#¨Docker 快速搭建Aria2 不含UI¨
#¨v: 0.0.1¨ 
#¨By: xinwen¨ 
echo ¨docker: aria2¨ 
read -t 30 -n 1 -p "开始安装吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	read -s -p "设置连接端口[默认2346]:" port 
	if [[		  ! -n "$port" ]]; then
		#echo -e "\033[31m 安装错误.未设置连接端口 \033[0m"
		#exit 0
		port=2346
	fi
	echo
	read -p "设置连接密码:" passwd 
	if [[ ! -n "$passwd" ]]; then
		echo -e "\033[31m 安装错误.未设置连接密码 \033[0m"
		exit 0
	fi
	echo -e "\033[32m 开始安装Aria2 \033[0m"
	#开始执行
	docker run --name myaria2 -d -p $port:6800 -p 880:80 -p 800:8080 -v /var/xinwen/www/download:/data -e SECRET=$passwd xujinkai/aria2-with-webui
	echo -e "\033[32m 安装完成 \033[0m"
	echo -e "\033[32m Aria2 下载目录:/var/xinwen/www/download \033[0m"
	echo -e "\033[32m Aria2 连接端口:$port \033[0m"
	echo -e "\033[32m Aria2 连接密码:$passwd \033[0m"
	echo -e "\033[32m Aria2 后台管理:http://yourip:880/ \033[0m"
	echo -e "\033[32m Aria2 下载地址:http://yourip/download 或 http://yourip:800/ \033[0m"
	cd /root
	exit 0
else
	echo 
	echo -e  "\033[31m 取消安装 \033[0m"
	exit 0
fi 
