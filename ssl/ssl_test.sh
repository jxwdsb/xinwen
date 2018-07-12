#!/bin/bash
read -t 30 -n 1 -p "开始配置吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	cd /var/xinwen 
	wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/sslforfree.zip 
	7z x sslforfree.zip -r -o/var/xinwen/nginx -y 
	cd /var/xinwen/nginx 
	if [[ -e server.crt ]]; then
		rm server.crt
	fi
	cat certificate.crt ca_bundle.crt > server.crt
	rm /var/xinwen/sslforfree.zip 
	rm /var/xinwen/nginx/certificate.crt
	rm /var/xinwen/nginx/ca_bundle.crt
	rm /var/xinwen/nginx/defult.conf
	wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/default.conf 
	docker restart mynginx 
	#docker exec -i -t mynginx /bin/bash -c 'nginx -s reload' 重载配置也行
	cd /root
else 
	echo -e  "\033[31m 取消安装 \033[0m" 
fi
