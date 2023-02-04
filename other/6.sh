#!/bin/bash

die() {
	local cmd=$1
	local errorC=$2
	if [[ errorC -gt 1 ]]; then
		echo -e "\033[31m错误太多次 $cmd \033[0m"
		exit;
	fi
	errorC=$(($errorC+1))
	eval ${cmd} || die "$cmd" $errorC
	exit 1
}

if [[ $EUID -ne 0 ]]; then
	echo "权限需要提升:该安装程序必须由root或sudo执行" 1>&2
	exit 1
fi

#screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh

#参考 http://www.cnblogs.com/stevensfollower/p/5093001.html
#大于0 就是找到了
linux_version=`uname -v`
if [[ `awk -v a="$linux_version" -v b="Debian" 'BEGIN{print index(a,b)}'` -le 0 ]]; then
	echo -e "\033[31m 不支持的系统 目前仅支持debian 系统 \033[0m"
	exit;
fi

echo "1.HOME 设置"
echo "2.同步资源"

read -n1 -p "请选择:" answer
case $answer in
	A | a | 1) echo
		echo -e "\033[32mcontinue \033[0m";;
	B | b | 2) echo
		echo -e "\033[32mcontinue \033[0m";;
	*)
		echo -e "\033[31mgoodbye \033[0m"
		exit;;
esac

cd /root
apt update >> /dev/null 2>&1
apt upgrade -y >> /dev/null 2>&1

errorC=0
while [[ `type -t curl` == "" ]]; do
	if [[ errorC -gt 1 ]]; then
		echo -e "\033[31m 安装 curl 错误太多次 \033[0m"
		exit;
	fi
	errorC=$(($errorC+1))
	cmd="apt -y install curl wget >> /dev/null 2>&1"
	eval ${cmd} || die "$cmd"
done

case $answer in
	A | a | 1)

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'` && echo $ip

		errorC=0
		while [[ `type -t nginx` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m 安装 nginx 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait install nginx \033[0m";

			curl -sSL https://packages.sury.org/nginx/README.txt | bash -x
			
			cmd="apt -y install nginx >> /dev/null 2>&1"
			eval ${cmd} || die "$cmd"
			
			cmd="apt -y install lua5.4 liblua5.4-dev luajit libnginx-mod-http-lua >> /dev/null 2>&1"
			eval ${cmd} || die "$cmd"

			domainName=$ip
			mkdir -m 777 /var/www/$domainName
			echo '<html>Hello</html>' > /var/www/${domainName}/index.html
			echo -e "\t\nserver {\n\tlisten 80;\n\tserver_name  ${domainName};\n\tclient_max_body_size 200m;\n\troot /var/www/${domainName};\n\tlocation  ~ ^/(files|aria2-downloads) {\n\t\tcharset utf-8;\n\t\tautoindex on;\n\t\tautoindex_exact_size off;\n\t\tautoindex_localtime on;\n\t}\n\tlocation  /phpmyadmin {\n\t\tindex index.html index.php;\n\t\tlocation ~ \.php\$ {\n\t\t\troot\t\t   /var/www/${domainName};\n\t\t\tfastcgi_pass   unix:/run/php/php-fpm.sock;\n\t\t\tfastcgi_index  index.php;\n\t\t\tfastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;\n\t\t\tinclude\t\tfastcgi_params;\n\t\t}\n\t}\n}\n\nserver {\n\tlua_code_cache off;\n\tdefault_type 'text/plain';\n\tlua_need_request_body on;\n\tlisten 81;\n\tserver_name  ${domainName};\n\troot /var/www/other;\n\tlocation / {\n\t\trewrite_by_lua_file /var/www/other/index.lua;\n\t\tindex  index.html index.htm index.php;\n\t}\n\tlocation  /files {\n\t\tcharset utf-8;\n\t\tautoindex on;\n\t\tautoindex_exact_size off;\n\t\tautoindex_localtime on;\n\t}\n}\n" >  /etc/nginx/conf.d/$domainName.new.conf

			#配置 nginx运行用户 www-data 改成 root  用于支持软链接
			sed -i "s?user www-data;?user root;#user www-data;?g" /etc/nginx/nginx.conf

			systemctl enable nginx
			systemctl restart nginx
		done

		errorC=0
		while [[ `type -t docker` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m 安装 docker 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))

			curl -sSL https://get.docker.com/ | sh
		done

		errorC=0
		while [[ `docker inspect hoppscotch 2> /dev/null` == "[]" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m docker hoppscotch 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait docker hoppscotch \033[0m";
			docker run --rm --name hoppscotch -d -p 3000:3000 hoppscotch/hoppscotch:latest
		done

		errorC=0
		while [[ `docker inspect aria2-pro 2> /dev/null` == "[]" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m docker aria2-pro 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait docker aria2-pro \033[0m";
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

			rm /var/www/${ip}/aria2-downloads
			ln -s /root/aria2-downloads /var/www/${ip}/aria2-downloads
		done

		errorC=0
		while [[ `docker inspect ariang 2> /dev/null` == "[]" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m docker ariang 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait docker ariang \033[0m";
			docker run -d \
				--name ariang \
				--log-opt max-size=1m \
				--restart unless-stopped \
				-p 6880:6880 \
				p3terx/ariang
		done

		errorC=0
		while [[ `docker inspect mailserver 2> /dev/null` == "[]" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m docker mailserver 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait docker mailserver \033[0m";
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
		done

		echo -e "\033[32mposte mailserver	:   http://${ip}:880/ \033[0m"
		echo -e "\033[32mhoppscotch		  :   http://${ip}:3000/ \033[0m"
		echo -e "\033[32mariang			  :   http://${ip}:6880/ \033[0m"
		echo -e "\033[32maria download route :   /root/aria2-downloads \033[0m"

	exit;;
	B | b | 2)
		#apt -y purge php8.0-cli php8.0-curl php8.0-mysql php8.0-pgsql php8.0-mbstring php8.0-imagick php8.0-gd php8.0-xml php8.0-zip

		read -p "请输入业务名称:" business_name
		echo "$business_name"

		errorC=0
		while [[ `type -t redis mariadb` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m 安装 redis mariadb 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait install redis-server mariadb-server \033[0m";
			cmd="apt -y install redis-server mariadb-server >> /dev/null 2>&1"
			eval ${cmd} || die "$cmd"

			mysqladmin -uroot -proot password "root"
			FIND_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
			FIND_STR="max_connections="
			if [ `grep -c "$FIND_STR" $FIND_FILE` -ne '0' ];then
				echo "跳过设置"
				#exit 0
			else
				echo -e "\n\nmax_connections=3000" >> /etc/mysql/mariadb.conf.d/50-server.cnf
			fi
			systemctl restart mariadb
		done

		errorC=0
		while [[ `type -t php` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m 安装 php 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait install php \033[0m";
			curl -sSL https://packages.sury.org/php/README.txt | bash -x
			apt-cache showpkg php

			cmd="apt -y install php8.0-cli php8.0-curl php8.0-mysql php8.0-pgsql php8.0-mbstring php8.0-imagick php8.0-gd php8.0-xml php8.0-zip >> /dev/null 2>&1"
			eval ${cmd} || die "$cmd"
		done

		errorC=0
		while [[ `type -t git` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m 安装 git 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait install git \033[0m";
			cmd="apt -y install git >> /dev/null 2>&1"
			eval ${cmd} || die "$cmd"
		done
		
		cd /root
		echo -e "\033[32mwait git clone \033[0m";
		git clone https://github.com/jxwdsb/xinwen.git >> /dev/null 2>&1
		mv xinwen GitFiles

		errorC=0
		while [[ `type -t screen` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m 安装 screen 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			echo -e "\033[32mwait install screen \033[0m";
			cmd="apt -y install screen >> /dev/null 2>&1"
			eval ${cmd} || die "$cmd"
		done

		tag=`php /root/GitFiles/other/init/other/phpmyadmin.php`
		if [[ $tag -ne "noUp" ]]; then
			rm -rf /root/GitFiles/other/phpmyadmin

			pname=phpMyAdmin-$tag-all-languages && echo $pname

			wget https://files.phpmyadmin.net/phpMyAdmin/$tag/$pname.tar.gz
			tar xzf $pname.tar.gz
			mv $pname phpmyadmin
			rm -rf $pname.tar.gz
			mv phpmyadmin /root/GitFiles/other

			mkdir -m 777 /root/GitFiles/other/phpmyadmin/tmp
		fi
		cp -rf /root/GitFiles/other/phpmyadmin /root/phpmyadmin

		screen -R p1 -X quit >> /dev/null 2>&1
		screen -dmS p1
		screen -r p1 -p 0 -X stuff "php -S 0.0.0.0:8000 -t /root/phpmyadmin"
		screen -r p1 -p 0 -X stuff $'\n' #执行回车

		cd /root/GitFiles/other/init/other
		newV=`php -r "if (file_exists('composer.phar') && hash_file('sha256', 'composer.phar') === file_get_contents('https://getcomposer.org/download/latest-stable/composer.phar.sha256')) { echo 'noUp'; } else { echo 'haveUp';} echo PHP_EOL;"`
		if [[ $newV -ne "noUp" ]]; then
			php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
			php composer-setup.php
			php -r "unlink('composer-setup.php');"
		fi
		cp composer.phar /usr/local/bin/composer

		current=`date "+%Y-%m-%d %H:%M:%S"`
		timeStamp=`date -d "$current" +%s` 
		currentTimeStamp=$(((timeStamp*1000+10#`date "+%N"`/1000000)/1000)) #将current转换为时间戳，精确到秒

		cd /root

		errorC=0
		echo -e "\033[32mwait composer workerman/webman \033[0m";
		while [[ $(composer create-project workerman/webman -q 2> /dev/null | grep ".php line ") != "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m docker ariang 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			rm -rf webman
		done

		cd /root/webman

		errorC=0
		echo -e "\033[32mwait composer webman/gateway-worker \033[0m";
		while [[ $(composer require webman/gateway-worker -q 2> /dev/null) != "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m composer webman/gateway-worker 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
		done

		cp -af /root/GitFiles/other/init/webman/* ./

		errorC=0
		echo -e "\033[32mwait composer webman/medoo \033[0m";
		while [[ $(composer require webman/medoo -q 2> /dev/null) != "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m composer webman/medoo 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
		done

		errorC=0
		echo -e "\033[32mwait composer pragmarx/google2fa \033[0m";
		while [[ $(composer require pragmarx/google2fa -q 2> /dev/null) != "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m composer pragmarx/google2fa 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
		done

		errorC=0
		echo -e "\033[32mwait composer bacon/bacon-qr-code \033[0m";
		while [[ $(composer require bacon/bacon-qr-code -q 2> /dev/null) != "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m composer bacon/bacon-qr-code 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
		done

		errorC=0
		echo -e "\033[32mwait composer phpoffice/phpspreadsheet \033[0m";
		while [[ $(composer require phpoffice/phpspreadsheet -q 2> /dev/null) != "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e "\033[31m composer phpoffice/phpspreadsheet 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
		done

		#https://www.workerman.net/q/9286 开启控制器复用
		sed -i "s#'controller_reuse' => false#'controller_reuse' => true#" ./config/app.php

		#修改上传文件大小限制 默认 10 M修改后 800 M 修改后需要重启webman
		sed -i "s#10 \* 1024 \* 1024#800 \* 1024 \* 1024#" ./config/server.php

		rm -rf /root/webman/app
		rm -rf /root/webman/plugin/webman/gateway
		rm -rf /root/webman/public
		rm -rf /root/webman/config/plugin/webman/medoo
		
		cd /root/GitFiles/http_service_files
		mkdir -m 755 $business_name
		cp ./default/* $business_name

		ln -s /root/GitFiles/http_service_files/$business_name/app /root/webman/app
		ln -s /root/GitFiles/http_service_files/$business_name/gateway /root/webman/plugin/webman/gateway
		ln -s /root/GitFiles/http_service_files/$business_name/public /root/webman/public
		ln -s /root/GitFiles/http_service_files/$business_name/medoo /root/webman/config/plugin/webman/medoo

		screen -R webman -X quit >> /dev/null 2>&1
		screen -dmS webman
		screen -r webman -p 0 -X stuff "cd /root/webman && php start.php start"
		screen -r webman -p 0 -X stuff $'\n' #执行回车

		screen -R fileUpdate -X quit >> /dev/null 2>&1
		screen -dmS fileUpdate
		screen -r fileUpdate -p 0 -X stuff "php /root/GitFiles/other/fileUpdate.php"
		screen -r fileUpdate -p 0 -X stuff $'\n' #执行回车

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'`
		echo -e "\033[32mphpmyadmin		  :   http://${ip}:8000/ \033[0m"
		echo -e "\033[32mwebman			  :   http://${ip}:8787/ \033[0m"
	exit;;
esac

