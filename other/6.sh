#!/bin/bash

die() {
	local cmd=$1
	local errorC=$2
	if [[ errorC -gt 1 ]]; then
		echo -e  "\033[31m错误太多次 $cmd \033[0m"
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

#参考 http://www.cnblogs.com/stevensfollower/p/5093001.html
#大于0 就是找到了
linux_version=`uname -v`
if [[ `awk -v a="$linux_version" -v b="Debian" 'BEGIN{print index(a,b)}'` -le 0 ]]; then
	echo -e  "\033[31m 不支持的系统 目前仅支持debian 系统 \033[0m"
	exit;
fi

echo "1.HOME 设置"
echo "2.同步文件"
echo "3.同步文件 并获取最新"
read -n1 -p "请选择:" answer
case $answer in
	A | a | 1) echo
		echo -e "\033[32mcontinue \033[0m";;
	B | b | 2) echo
		echo -e "\033[32mcontinue \033[0m";;
	C | c | 3) echo
		echo -e "\033[32mcontinue \033[0m";;
	*) echo
		echo -e  "\033[31mgoodbye \033[0m"
		exit;;
esac

cd /root
apt update
apt upgrade -y

errorC=0
while [[ `type -t curl` == "" ]]; do
	if [[ errorC -gt 1 ]]; then
		echo -e  "\033[31m 安装 curl 错误太多次 \033[0m"
		exit;
	fi
	cmd="apt install -y curl wget"
	eval ${cmd} || die "$cmd"
	errorC=$(($errorC+1))
done

function init() {
	cmd="apt -y install redis-server mariadb-server"
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

	curl -sSL https://packages.sury.org/php/README.txt | bash -x
	apt-cache showpkg php

	cmd="apt -y install php8.0-cli php8.0-curl php8.0-mysql php8.0-pgsql php8.0-mbstring php8.0-imagick php8.0-gd php8.0-xml php8.0-zip"
	eval ${cmd} || die "$cmd"

	cmd="apt -y install git"
	eval ${cmd} || die "$cmd"
	
	cd /root
	git clone https://github.com/jxwdsb/xinwen.git
	mv xinwen GitFiles

	cmd="apt -y install screen"
	eval ${cmd} || die "$cmd"
}

case $answer in
	A | a | 1) echo

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'` && echo $ip

		errorC=0
		while [[ `type -t nginx` == "" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e  "\033[31m 安装 nginx 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))

			curl -sSL https://packages.sury.org/nginx/README.txt | bash -x
			
			cmd="apt -y install nginx"
			eval ${cmd} || die "$cmd"
			
			cmd="apt -y install lua5.4 liblua5.4-dev luajit libnginx-mod-http-lua"
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
				echo -e  "\033[31m 安装 docker 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))

			curl -sSL https://get.docker.com/ | sh
		done

		errorC=0
		while [[ `docker inspect hoppscotch 2> /dev/null` == "[]" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e  "\033[31m docker hoppscotch 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))

			docker run --rm --name hoppscotch -d -p 3000:3000 hoppscotch/hoppscotch:latest
		done

		errorC=0
		while [[ `docker inspect aria2-pro 2> /dev/null` == "[]" ]]; do
			if [[ errorC -gt 1 ]]; then
				echo -e  "\033[31m docker aria2-pro 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))

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
				echo -e  "\033[31m docker ariang 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))

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
				echo -e  "\033[31m docker mailserver 错误太多次 \033[0m"
				exit;
			fi
			errorC=$(($errorC+1))
			
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
	B | b | 2) echo
		init

		cp -rf /root/GitFiles/other/phpmyadmin /root/phpmyadmin

		screen -R p1 -X quit
		screen -dmS p1
		screen -r p1 -p 0 -X stuff "php -S 0.0.0.0:8000 -t /root/phpmyadmin"
		screen -r p1 -p 0 -X stuff $'\n' #执行回车

		screen -ls

		cp /root/GitFiles/other/webman_init/other/composer.phar /usr/local/bin/composer

		while read line
		do
			ln -s /root/GitFiles/other/$line /root/webman
		done < /root/GitFiles/other/webman_name

		screen -R webman -X quit
		screen -dmS webman
		screen -r webman -p 0 -X stuff "cd /root/webman && php start.php start"
		screen -r webman -p 0 -X stuff $'\n' #执行回车

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'` && echo $ip
		echo -e "\033[32mphpmyadmin		  :   http://${ip}:8000/ \033[0m"
		echo -e "\033[32mwebman			  :   http://${ip}:8787/ \033[0m"
	exit;;
	C | c | 3) echo
		#apt -y purge php8.0-cli php8.0-curl php8.0-mysql php8.0-pgsql php8.0-mbstring php8.0-imagick php8.0-gd php8.0-xml php8.0-zip

		init

		tag=`php /root/GitFiles/other/webman_init/other/phpmyadmin.php` && echo $tag
		if [[ $tag -ne "noUp" ]]; then
			rm -rf /root/GitFiles/other/phpmyadmin

			pname=phpMyAdmin-$tag-all-languages && echo $pname

			wget https://files.phpmyadmin.net/phpMyAdmin/$tag/$pname.tar.gz
			tar xzf $pname.tar.gz
			mv $pname phpmyadmin
			rm -rf $pname.tar.gz
			mv phpmyadmin /root/GitFiles/other

			mkdir -m 777 /root/GitFiles/other/phpmyadmin/tmp
			cp -rf /root/GitFiles/other/phpmyadmin /root/phpmyadmin
		fi

		screen -R p1 -X quit
		screen -dmS p1
		screen -r p1 -p 0 -X stuff "php -S 0.0.0.0:8000 -t /root/phpmyadmin"
		screen -r p1 -p 0 -X stuff $'\n' #执行回车

		screen -ls

		cd /root/GitFiles/other/webman_init/other
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

		cd /root/GitFiles/other

		cmd="composer create-project workerman/webman -q"
		eval ${cmd} || die "$cmd"
		
		mv webman webman_$currentTimeStamp
		rm -rf /root/webman
		ln -s /root/GitFiles/other/webman_$currentTimeStamp /root/webman
		echo -e "webman_$currentTimeStamp" > /root/GitFiles/other/webman_name

		cd /root/webman

		cmd="composer require webman/gateway-worker -q"
		eval ${cmd} || die "$cmd"

		cp -af /root/GitFiles/other/webman_init/webman/* ./

		cmd="composer require webman/medoo -q"
		eval ${cmd} || die "$cmd"

		cmd="composer require pragmarx/google2fa -q"
		eval ${cmd} || die "$cmd"
		cmd="composer require bacon/bacon-qr-code -q"
		eval ${cmd} || die "$cmd"

		cmd="composer require phpoffice/phpspreadsheet -q"
		eval ${cmd} || die "$cmd"

		#https://www.workerman.net/q/9286 开启控制器复用
		sed -i "s#'controller_reuse' => false#'controller_reuse' => true#" ./config/app.php

		#修改上传文件大小限制 默认 10 M修改后 800 M 修改后需要重启webman
		sed -i "s#10 \* 1024 \* 1024#800 \* 1024 \* 1024#" ./config/server.php

		rm -rf /root/webman/app
		rm -rf /root/webman/plugin/webman/gateway
		rm -rf /root/webman/public

		ln -s /root/GitFiles/http_service_files/app /root/webman/app
		ln -s /root/GitFiles/http_service_files/gateway /root/webman/plugin/webman/gateway
		ln -s /root/GitFiles/http_service_files/public /root/webman/public

		screen -R webman -X quit
		screen -dmS webman
		screen -r webman -p 0 -X stuff "cd /root/webman && php start.php start"
		screen -r webman -p 0 -X stuff $'\n' #执行回车

		ip=`ip a|grep inet|grep brd|grep -v eth0:|grep -v 127.0.0.1|grep -v inet6|grep -v docker|awk '{print $2}'|awk -F'[/]' '{print $1}'|awk -F'[\n]' '{print $1}'` && echo $ip
		echo -e "\033[32mphpmyadmin		  :   http://${ip}:8000/ \033[0m"
		echo -e "\033[32mwebman			  :   http://${ip}:8787/ \033[0m"
	exit;;
esac

