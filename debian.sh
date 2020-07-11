#!/bin/bash
#¨在Debian上安装Docker 快速搭建网站环境¨
#¨v: 0.0.1¨
#¨By: xinwen¨
echo ¨debian [docker: mymariadb php-fpm nginx]¨
read -s -p "设置密码:" passwd 
if [[ ! -n "$passwd" ]]; then
	echo -e "\033[31m 安装错误.未设置密码 \033[0m"
	exit 0
fi
echo
echo -e "\033[32m 开始安装 \033[0m"
apt-get update -y
apt-get install wget -y #防止是复制粘贴的代码
apt-get install curl -y 
curl -sSL https://get.docker.com/ | sh
#docker run -d --name  speedtest -p 0.0.0.0:8099:80 adolfintel/speedtest:latest
apt-get install p7zip-full -y

mkdir /var/xinwen
chmod -R 755 /var/xinwen
cd /var/xinwen
mkdir 123 nginx www php
chmod -R 755 123 nginx www php
echo -e 'FROM php:fpm\nRUN apt-get update && docker-php-ext-install mysqli && docker-php-ext-install pdo_mysql && docker-php-ext-install pcntl ' > /var/xinwen/123/Dockerfile


docker pull mariadb 
docker run --name mymariadb -d -e MYSQL_ROOT_PASSWORD=$passwd mariadb 

docker pull php:fpm
cd /var/xinwen/123 
docker build -t myphp .
docker run --name myphp -d -p 8281:8281 -p 8280:8280 -p 8282:8282 -v /var/xinwen/www:/var/www/html -v /var/xinwen/php:/usr/local/etc/php1 --link mymariadb:mysql myphp 
docker exec -i -t myphp /bin/bash -c 'mv /usr/local/etc/php/* /usr/local/etc/php1'
docker exec -i -t myphp /bin/bash -c 'rm -rf /usr/local/etc/php'
docker exec -i -t myphp /bin/bash -c 'ln -s /usr/local/etc/php1 /usr/local/etc/php'
docker restart myphp

docker pull nginx 
docker run --name mynginx -d -p 80:80 -p 443:443 -v /var/xinwen/www:/usr/share/nginx/html1 -v /var/xinwen/nginx:/etc/nginx/conf.d1 --link myphp:php nginx
docker exec -i -t mynginx /bin/bash -c 'mv /etc/nginx/conf.d/* /etc/nginx/conf.d1'
docker exec -i -t mynginx /bin/bash -c 'rm -rf /etc/nginx/conf.d'
docker exec -i -t mynginx /bin/bash -c 'ln -s /etc/nginx/conf.d1 /etc/nginx/conf.d'
docker exec -i -t mynginx /bin/bash -c 'mv /usr/share/nginx/html/* /usr/share/nginx/html1'
docker exec -i -t mynginx /bin/bash -c 'rm -rf /usr/share/nginx/html'
docker exec -i -t mynginx /bin/bash -c 'ln -s /usr/share/nginx/html1 /usr/share/nginx/html'
docker restart mynginx

mv /var/xinwen/nginx/default.conf /var/xinwen/nginx/default.conf.backup
wget -P /var/xinwen/nginx https://raw.githubusercontent.com/jxwdsb/xinwen/master/default.conf
docker restart mynginx

cd /var/xinwen/www
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip
7z x phpMyAdmin-latest-all-languages.zip -r -o/var/xinwen/www -y
mv phpMyAdmin-5.0.2-all-languages phpmyadmin
wget -P /var/xinwen/www/phpmyadmin https://raw.githubusercontent.com/jxwdsb/xinwen/master/config.inc.php
chmod -R 755 phpmyadmin


ln -s /var/xinwen /root/xinwen
cd /root

#docker stop mynginx && docker rm mynginx
#docker stop myphp && docker rm myphp
#docker stop mymariadb && docker rm mymariadb
#rm -rf /var/xinwen
#rm -f /root/test.sh