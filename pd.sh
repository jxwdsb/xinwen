#!/bin/bash
#¨Docker 快速搭建网站环境¨
#¨v: 0.0.3¨
#¨By: xinwen¨
#判断系统版本
echo ¨docker: mymariadb php-fpm nginx phpmyadmin mysql¨
#参考 http://www.cnblogs.com/stevensfollower/p/5093001.html
start=`uname -v`
#awk -v a="$start" -v b="Debian" 'BEGIN{print index(a,b)}'
#大于0 就是找到了
weizhi=`awk -v a="$start" -v b="Debian" 'BEGIN{print index(a,b)}'`
if [[ $weizhi > 0 ]]; then
	#echo "是 Debian 系统"
	weizhi="1"
else
	#echo "不是 Debian 系统"
	weizhi=`awk -v a="$start" -v b="Ubuntu" 'BEGIN{print index(a,b)}'`
	if [[ $weizhi > 0 ]]; then
		weizhi="1"
	else
		start=`cat /proc/version`
		weizhi=`awk -v a="$start" -v b="centos" 'BEGIN{print index(a,b)}'`
		#read -t 30 -n 1 -p "是Centos系统吗?[y/n]:" start 
		#if [[ $start == "y" ]]; then
		if [[ $start > 0 ]]; then
			weizhi="2"
		else
			echo
			echo -e  "\033[31m 取消安装,当前系统暂不支持 \033[0m"
			exit 0
		fi
	fi
fi 
echo
read -t 30 -n 1 -p "开始安装吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	read -s -p "设置SSR连接端口[默认8887]:" ssrport 
	if [[ ! -n "$port" ]]; then
		ssrport=8887
	fi
	echo
	read -s -p "设置Aria2连接端口[默认2346]:" aria2port 
	if [[ ! -n "$port" ]]; then
		aria2port=2346
	fi
	echo
		read -s -p "设置密码:" passwd 
		if [[ ! -n "$passwd" ]]; then
			echo -e "\033[31m 安装错误.未设置密码 \033[0m"
			exit 0
		fi
		echo
		echo -e "\033[32m 开始安装 \033[0m"
		#开始执行
		cd /var 
		wget -P /var https://raw.githubusercontent.com/jxwdsb/xinwen/master/xinwen.7z
		if [[ $weizhi == "1" ]]; then
			apt-get update -y
			#apt-get install wget 
			apt-get install p7zip-full -y
			7z x xinwen.7z -r -o/var -y
			echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list 
			apt-get update -y
			apt-get install docker.io -y 
		else
			yum update  -y
			#yum install wget 
			yum install epel-release -y
			yum install p7zip -y
			7za x xinwen.7z -r -o/var -y
			#yum update 
			yum install docker-io -y 
			service docker start
		fi
		#############判断配置文件
		if [[ ! -f "/var/xinwen/nginx/default.conf" ]]; then
			mv /var/xinwen/nginx/default.conf1 /var/xinwen/nginx/default.conf
		fi
		if [[ ! -f "/var/xinwen/www/index.php" ]]; then
			mv /var/xinwen/www/index.php1 /var/xinwen/www/index.php
		fi
		if [[ ! -f "/var/xinwen/123/Dockerfile" ]]; then
			mv /var/xinwen/123/Dockerfile1 /var/xinwen/123/Dockerfile
		fi
		############结束判断
		chmod -R 755 ./xinwen
		rm xinwen.7z 
		docker pull mariadb 
		docker pull php:fpm
		docker pull nginx 
		docker pull phpmyadmin/phpmyadmin 
		docker run --name mymariadb -d -e MYSQL_ROOT_PASSWORD=$passwd mariadb 
		cd /var/xinwen/123 
		docker build -t myphp .
		docker run --name myphp -d -p 8281:8281 -p 8280:8280 -p 8282:8282 -v /var/xinwen/www:/var/www/html --link mymariadb:mysql myphp 
		docker run --name mynginx -d -p 80:80 -p 443:443   -v /var/xinwen/www:/usr/share/nginx/html -v /var/xinwen/nginx:/etc/nginx/conf.d --link myphp:php   nginx 
		docker restart mynginx 
		docker run --name myadmin -d --link mymariadb:db -p 8080:80 phpmyadmin/phpmyadmin
		
		############################
		echo -e "\033[32m 开始安装SSR \033[0m"
		#开始执行
		#包含在xinwen 7z里#wget -P /var/xinwen/ssr https://raw.githubusercontent.com/jxwdsb/xinwen/master/shadowsocks.json 
		if [[ ! -f "/var/xinwen/ssr/shadowsocks.json" ]]; then
			mv /var/xinwen/ssr/shadowsocks.json1 /var/xinwen/ssr/shadowsocks.json
			sed -i "s/xinwen/$passwd/g" `grep xinwen -rl /var/xinwen/ssr`
		fi
		#chmod -R 755 /var/xinwen/ssr
		chmod -R 777 /var/xinwen
		docker pull 4kerccc/shadowsocksr
		docker run --name myssr -itd -p $ssrport:80 -v /var/xinwen/ssr/shadowsocks.json:/etc/shadowsocks.json 4kerccc/shadowsocksr
		ip=`ifconfig eth0 | grep 'inet ' | sed s/^.*inet//g | sed s/netmask.*$//g | sed 's/ //g'`
		############################
		echo -e "\033[32m 开始安装Aria2 \033[0m"
		#开始执行
		docker run --name myaria2 -d -p $aria2port:6800 -p 880:80 -p 800:8080 -v /var/xinwen/www/download:/data -e SECRET=$passwd xujinkai/aria2-with-webui
		
		echo -e "\033[32m 安装完成 \033[0m"
		echo -e "\033[32m nginx 站点目录:/var/xinwen/www \033[0m"
		echo -e "\033[32m nginx 配置文件:/var/xinwen/nginx \033[0m"

		echo -e "\033[32m SSR 服务器IP地址: "$ip" \033[0m"
		echo -e "\033[32m SSR 远程端口: $ssrport \033[0m"
		echo -e "\033[32m SSR 密码: "$passwd" \033[0m"
		echo -e "\033[32m SSR 认证协议: auth_sha1_v4 \033[0m"
		echo -e "\033[32m SSR 混淆方式: http_simple \033[0m"
		echo -e "\033[32m SSR 加密方法: chacha20 \033[0m"
		echo -e "\033[32m SSR 配置文件 /var/xinwen/ssr/shadowsocks.json \033[0m"
		echo -e "\033[32m SSR 配置文件修改后执行 docker restart myssr \033[0m"

		echo -e "\033[32m Aria2 下载目录:/var/xinwen/www/download \033[0m"
		echo -e "\033[32m Aria2 连接端口:$aria2port \033[0m"
		echo -e "\033[32m Aria2 连接密码:$passwd \033[0m"
		echo -e "\033[32m Aria2 后台管理:http://"$ip":880/ \033[0m"
		echo -e "\033[32m Aria2 下载地址:http://"$ip"/download 或 http://"$ip":800/ \033[0m"
		cd /root
		exit 0
else
	echo 
	echo -e  "\033[31m 取消安装 \033[0m"
	exit 0
fi 