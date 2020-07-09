#!/bin/bash
#¨在Debian上删除Docker 快速删除网站环境¨
#¨v: 0.0.1¨
#¨By: xinwen¨
echo ¨debian del [docker: mymariadb php-fpm nginx]¨
read -s "确定删除? y" passwd 
if [[ $passwd != 'y' ]]; then
	echo -e "\033[31m 取消删除 \033[0m"
	exit 0
fi
echo
echo -e "\033[32m 开始删除 \033[0m"
docker stop mynginx && docker rm mynginx
docker stop myphp && docker rm myphp
docker stop mymariadb && docker rm mymariadb
rm -rf /var/xinwen
rm -f /root/test.sh