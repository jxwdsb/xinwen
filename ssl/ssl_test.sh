#!/bin/bash
read -t 30 -n 1 -p "开始安装吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	cd /var/xinwen 
	wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/sslforfree.zip 
	7z x sslforfree.zip -r -o/var/xinwen/nginx -y 
	cd /var/xinwen/nginx 
	cat file(/var/xinwen/nginx/certificate.crt) | while read line1
	do
		#什么也不干
	done
	cat file(/var/xinwen/nginx/ca_bundle.crt) | while read line2
	do
		#什么也不干
	done
	if [[ -e /var/xinwen/nginx/server.crt ]]; then
		rm /var/xinwen/nginx/server.crt
	fi
	echo ${line1}${line2} > /var/xinwen/nginx/server.crt
	rm /var/xinwen/sslforfree.zip 
	rm /var/xinwen/nginx/certificate.crt
	rm /var/xinwen/nginx/ca_bundle.crt
	rm /var/xinwen/nginx/defult.conf
	wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/defult.conf 
	docker restart mynginx 
else 
	echo -e  "\033[31m 取消安装 \033[0m" 
fi
