#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "权限需要提升:该安装程序必须由root或sudo执行" 1>&2
	exit 1
fi

#参考 http://www.cnblogs.com/stevensfollower/p/5093001.html
#大于0 就是找到了
linux_version=`uname -v`
if [[ `awk -v a="$linux_version" -v b="Debian" 'BEGIN{print index(a,b)}'` -le 0 ]]; then
	echo -e  "\033[31m 不支持的系统 目前仅支持debian 系统 \033[0m"
	exit;
fi

read -n1 -p "是否为HOME [Y/N]?" answer
case $answer in
	Y | y) echo
		echo -e "\033[32mcontinue \033[0m";;
	N | n) echo
		echo -e "\033[32mcontinue \033[0m";;
	*) echo
		echo -e  "\033[31mgoodbye \033[0m"
		exit;;
esac

cd /root
apt update
apt upgrade -y
apt install -y curl wget
case $answer in
	Y | y) echo
		curl -sSL https://packages.sury.org/nginx/README.txt | bash -x
		apt -y install nginx
		apt -y install lua5.4 liblua5.4-dev luajit libnginx-mod-http-lua
		systemctl enable nginx

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'` && echo $ip

		domainName=$ip
		mkdir -m 777 /var/www/$domainName
		echo '<html>Hello</html>' > /var/www/${domainName}/index.html
		echo -e "\t\nserver {\n\tlisten 80;\n\tserver_name  ${domainName};\n\tclient_max_body_size 200m;\n\troot /var/www/${domainName};\n\tlocation  ~ ^/(files|aria2-downloads) {\n\t\tcharset utf-8;\n\t\tautoindex on;\n\t\tautoindex_exact_size off;\n\t\tautoindex_localtime on;\n\t}\n\tlocation  /phpmyadmin {\n\t\tindex index.html index.php;\n\t\tlocation ~ \.php\$ {\n\t\t\troot\t\t   /var/www/${domainName};\n\t\t\tfastcgi_pass   unix:/run/php/php-fpm.sock;\n\t\t\tfastcgi_index  index.php;\n\t\t\tfastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;\n\t\t\tinclude\t\tfastcgi_params;\n\t\t}\n\t}\n}\n\nserver {\n\tlua_code_cache off;\n\tdefault_type 'text/plain';\n\tlua_need_request_body on;\n\tlisten 81;\n\tserver_name  ${domainName};\n\troot /var/www/other;\n\tlocation / {\n\t\trewrite_by_lua_file /var/www/other/index.lua;\n\t\tindex  index.html index.htm index.php;\n\t}\n\tlocation  /files {\n\t\tcharset utf-8;\n\t\tautoindex on;\n\t\tautoindex_exact_size off;\n\t\tautoindex_localtime on;\n\t}\n}\n" >  /etc/nginx/conf.d/$domainName.new.conf

		ln -s /root/aria2-downloads /var/www/${domainName}/aria2-downloads

		#配置 nginx运行用户 www-data 改成 root  用于支持软链接
		sed -i "s?user www-data;?user root;#user www-data;?g" /etc/nginx/nginx.conf

		systemctl restart nginx

		curl -sSL https://get.docker.com/ | sh

		docker run --rm --name hoppscotch -d -p 3000:3000 hoppscotch/hoppscotch:latest

		docker run -d \
			--name aria2-pro \
			--restart unless-stopped \
			--log-opt max-size=1m \
			-e PUID=$UID \
			-e PGID=$GID \
			-e UMASK_SET=022 \
			-e RPC_SECRET=123456 \
			-e RPC_PORT=6800 \
			-p 6800:6800 \
			-e LISTEN_PORT=6888 \
			-p 6888:6888 \
			-p 6888:6888/udp \
			-v $PWD/aria2-config:/config \
			-v $PWD/aria2-downloads:/downloads \
			p3terx/aria2-pro

		docker run -d \
			--name ariang \
			--log-opt max-size=1m \
			--restart unless-stopped \
			-p 6880:6880 \
			p3terx/ariang

		#邮件服务器 需要开放25端口
		#25,110,143,465,587,993,995,4190
		#域名解析一个MX类型 @ MX mail.nldzz.cn 优先级10 或者随便写
		docker run -d \
			-p 880:80 -p 8443:443 -p 25:25 -p 110:110 -p 143:143 -p 465:465 -p 587:587 -p 993:993 -p 995:995 -p 4190:4190 \
			-e TZ=Asia/Shanghai \
			-e "HTTPS=OFF" \
			-v /root/mail-data:/data \
			--name "mailserver" \
			-h "mail.mdomain.com" \
			--restart=always \
			-t analogic/poste.io

		echo -e "\033[32mposte mailserver    :   http://${domainName}:880/ \033[0m"
		echo -e "\033[32mhoppscotch          :   http://${domainName}:3000/ \033[0m"
		echo -e "\033[32mariang              :   http://${domainName}:6880/ \033[0m"
		echo -e "\033[32maria download route :   /root/aria2-downloads \033[0m"

	exit;;
	N | n) echo
		curl -sSL https://packages.sury.org/php/README.txt | bash -x
		apt-cache showpkg php
		apt -y install php8.0-cli php8.0-curl php8.0-mysql php8.0-pgsql php8.0-mbstring php8.0-imagick php8.0-gd php8.0-xml php8.0-zip
		#apt -y purge php8.0-cli php8.0-curl php8.0-mysql php8.0-pgsql php8.0-mbstring php8.0-imagick php8.0-gd php8.0-xml php8.0-zip

		apt -y install git
		cd /root
		git clone https://github.com/jxwdsb/xinwen.git
		mv xinwen GitFiles

		apt -y install git screen

		tag=`php /root/GitFiles/ready/other/phpmyadmin.php` && echo $tag
		pname=phpMyAdmin-$tag-all-languages && echo $pname

		wget https://files.phpmyadmin.net/phpMyAdmin/$tag/$pname.tar.gz
		tar xzf $pname.tar.gz
		mv $pname phpmyadmin
		rm -rf $pname.tar.gz
		mv phpmyadmin /root

		mkdir -m 777 /root/phpmyadmin/tmp/

		screen -R p1 -X quit
		screen -dmS p1
		screen -r p1 -p 0 -X stuff "cd /root && php -S 0.0.0.0:8000 -t /root/phpmyadmin"
		screen -r p1 -p 0 -X stuff $'\n' #执行回车

		screen -ls

		php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
		php composer-setup.php
		php -r "unlink('composer-setup.php');"
		mv composer.phar /usr/local/bin/composer

		current=`date "+%Y-%m-%d %H:%M:%S"`
		timeStamp=`date -d "$current" +%s` 
		currentTimeStamp=$(((timeStamp*1000+10#`date "+%N"`/1000000)/1000)) #将current转换为时间戳，精确到秒

		cd GitFiles
		rm -rf webman

		composer create-project workerman/webman -q
		mv webman webman_$currentTimeStamp
		ln -s webman_$currentTimeStamp webman
		cd webman
		composer require webman/gateway-worker -q

		cp -af ../ready/webman/* ./

		composer require webman/medoo -q

		composer require pragmarx/google2fa -q
		composer require bacon/bacon-qr-code -q

		composer require phpoffice/phpspreadsheet -q

		#https://www.workerman.net/q/9286 开启控制器复用
		sed -i "s#'controller_reuse' => false#'controller_reuse' => true#" ./config/app.php

		#修改上传文件大小限制 默认 10 M修改后 800 M 修改后需要重启webman
		sed -i "s#10 \* 1024 \* 1024#800 \* 1024 \* 1024#" ./config/server.php

		screen -R webman -X quit
		screen -dmS webman
		screen -r webman -p 0 -X stuff "cd /root/GitFiles/webman && php start.php start"
		screen -r webman -p 0 -X stuff $'\n' #执行回车

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'` && echo $ip
		echo -e "\033[32mphpmyadmin          :   http://${ip}:8000/ \033[0m"
		echo -e "\033[32mwebman              :   http://${ip}:8787/ \033[0m"

	exit;;
esac

