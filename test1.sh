#!/bin/bash
#¨Docker 快速搭建网站环境¨
#¨v: 0.0.1¨ 
#¨By: xinwen¨ 
echo ¨docker: mymariadb php-fpm nginx phpmyadmin mysql¨
read -t 30 -n 1 -p "开始修复吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	read -s -p "设置mymariadb_root密码:" passwd 
	if [[ ! -n "$passwd" ]]; then
		echo -e "\033[31m 安装错误.未设置数据库密码 \033[0m"
		exit 0
	fi
	echo -e "\033[32m 开始修复 \033[0m"
	#开始执行
	docker kill $(docker ps -a -q) 
	docker rm $(docker ps -a -q) 
	cd /var 
	apt-get install curl 
	curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://930e1f6b.m.daocloud.io -y
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
	echo -e "\033[32m 修复完成 \033[0m"
	echo -e "\033[32m nginx 站点目录:/var/xinwen/www \033[0m"
	echo -e "\033[32m nginx 配置文件:/var/xinwen/nginx \033[0m"
	exit 0
else
	echo 
	echo -e  "\033[31m 取消修复 \033[0m"
	exit 0
fi 
