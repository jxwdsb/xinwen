#!/bin/bash
#¨Docker 快速搭建网站环境¨
#¨v: 0.0.1¨
#¨By: xinwen¨
echo ¨docker: mymariadb php-fpm nginx phpmyadmin mysql¨
read -t 30 -n 1 -p "开始安装吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	read -s -p "设置mymariadb_root密码:" passwd 
	if [[ ! -n "$passwd" ]]; then
		echo -e "\033[31m 安装错误.未设置数据库密码 \033[0m"
		exit 0
	fi
	echo -e "\033[32m 开始安装 \033[0m"
	#开始执行
	apt-get update 
	apt-get install wget 
	apt-get install p7zip-full -y
	cd /var 
	wget -P /var https://raw.githubusercontent.com/jxwdsb/xinwen/master/xinwen.7z
	7z x xinwen.7z -pjxw12181218 -r -o/var -y
	echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list 
	apt-get update 
	apt-get install docker.io -y 
	docker pull mariadb:10.3.8 
	docker pull php:7.2.7-fpm 
	docker pull nginx:1.15.1 
	docker pull phpmyadmin/phpmyadmin:edge-4.8 
	docker run --name mymariadb -d -e MYSQL_ROOT_PASSWORD=$passwd mariadb:10.3.8 
	cd /var/xinwen/123 
	docker build -t myphp .
	docker run --name myphp -d -v /var/xinwen/www:/var/www/html --link mymariadb:mysql myphp 
	docker run --name mynginx -d -p 80:80 -p 443:443   -v /var/xinwen/www:/usr/share/nginx/html -v /var/xinwen/nginx:/etc/nginx/conf.d --link myphp:php   nginx:1.15.1 
	docker restart mynginx 
	docker run --name myadmin -d --link mymariadb:db -p 8080:80 phpmyadmin/phpmyadmin:edge-4.8
	echo -e "\033[32m 安装完成 \033[0m"
	echo -e "\033[32m nginx 站点目录:/var/xinwen/www \033[0m"
	echo -e "\033[32m nginx 配置文件:/var/xinwen/nginx \033[0m"
	cd /root
	exit 0
else
	echo 
	echo -e  "\033[31m 取消安装 \033[0m"
	exit 0
fi 
