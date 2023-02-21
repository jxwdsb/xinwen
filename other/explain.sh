
<< EOF
cd /root/GitFiles/webman && php start.php start

hostnamectl set-hostname test

apt -y install default-jdk keytool -exportcert -alias hbuilder -keystore ./mtzlogistics.keystore | openssl dgst -sha1 -binary |

卸载webman 不支持的php版本
apt autoremove php -y


=====
git 操作

git config --global user.email "1781642940@qq.com"
git config --global credential.helper store

git remote add xinwen https://github.com/jxwdsb/xinwen.git

cd /root/GitFiles
git add -A
git commit -m "update"
git push -u xinwen +main


#第一次
cd /root/GitFiles
git init
#git config --global user.name "jxwdsb"
git config --global user.email "1781642940@qq.com"
git config --global credential.helper store
git add -A
git commit -m "first commit" #会显示需要同步的文件名称
git branch -m main
git remote add xinwen https://github.com/jxwdsb/xinwen.git
git push -u xinwen +main

============
mysql mariadb
#https://www.runoob.com/w3cnote/linux-mysql-import-export-data.html
#导入 mysql -se "use byhd.jybeing.com;source /root/byhd_nldzz_cn.sql;"
mysql -se "create DATABASE asdasdasd;"


============
苹果登录报错
解决
/root/webman/vendor/griffinledingham/php-apple-signin/Vendor/JWT.php
public static $leeway = 0;
这里0改成5
参考
https://github.com/googleapis/google-api-php-client/issues/1341


============
sed -i 's/\#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && sed -i 's/\#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && systemctl restart ssh

supes.top 只需要 SSR Plus+ 和 PassWall 2 主题选择Material
把 security.debian.org 添加到代理
把 phpmyadmin.net 添加到代理


============
phpmyadmin

wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/phpmyadmin.php
tag_name=`php phpmyadmin.php`

curl -o phpMyAdmin-$tag_name-all-languages.tar.gz https://files.phpmyadmin.net/phpMyAdmin/$tag_name/phpMyAdmin-$tag_name-all-languages.tar.gz
tar xzf phpMyAdmin-$tag_name-all-languages.tar.gz
mv phpMyAdmin-$tag_name-all-languages phpmyadmin
rm -rf phpMyAdmin-$tag_name-all-languages.tar.gz
mv phpmyadmin /var/www/$domainName

mkdir -m 777 /var/www/$domainName/phpmyadmin/tmp/


============
golang

cd /root
curl -o go.php https://raw.githubusercontent.com/jxwdsb/xinwen/master/go.php
GoVersion=`php go.php`
wget https://go.dev/dl/$GoVersion.linux-amd64.tar.gz && tar xzf $GoVersion.linux-amd64.tar.gz && rm -rf $GoVersion.linux-amd64.tar.gz && echo -e '\nexport PATH=$PATH:/root/go/bin' >> /etc/profile && source /etc/profile

rm -f /root/go.php

php -v
go version


============
qm importdisk 100 /root/openwrt.img local-lvm
\password postgres


============
shift + F10
输入
OOBE\BYPASSNRO
没有空格


============
apt install -y ffmpeg

cd /root && php ffmpegSet.php
ffmpeg -i a5.png -vf "scale=iw/2:ih/2" a51.png 
ffmpeg -i a6.png -vf "scale=iw/2:ih/2" a61.png 

ffmpeg -i a5.png -vf "scale=iw*0.3:ih*0.3" a51.png 
ffmpeg -i a6.png -vf "scale=iw*0.3:ih*0.3" a61.png 
ffmpeg -i a5.png -vf "scale=iw*0.4:ih*0.4" a51.png 
ffmpeg -i a6.png -vf "scale=iw*0.4:ih*0.4" a61.png 
ffmpeg -i a2.png -vf "scale=iw*0.7:ih*0.7" a21.png 

ffmpeg -i 2.mp4 -y -f image2 -t 5 -s 352x240 -ss 00:00:03 2.jpg
ffmpeg -i /var/www/api.jybeing.com/videos/xc.mp4 -y -f image2 -t 5 -s 614x345 -ss 00:00:03 /var/www/api.jybeing.com/videos/xc.jpg
============
apt install -y lm-sensors

sensors

Package id 1:  +46.0°C  (high = +73.0°C, crit = +83.0°C)
Package id 0:  +42.0°C  (high = +73.0°C, crit = +83.0°C)

Package id 1:  +46.0°C  (high = +73.0°C, crit = +83.0°C)
Package id 0:  +41.0°C  (high = +73.0°C, crit = +83.0°C)

噪音44  43
cat /proc/cpuinfo | grep "cpu MHz"


============
#泛域名证书 ID 和 key 改成自己的
curl https://get.acme.sh | sh -s email=admin@nldzz.cn
export DP_Id="111111111111" #设置成自己的
export DP_Key="6ebb6681b361421d967516b0a0e43858"
/root/.acme.sh/acme.sh --issue --dns dns_dp -d nldzz.cn -d *.nldzz.cn

============
#表格处理
composer require phpoffice/phpspreadsheet -q
apt -y install php-xml php-zip
apt update && apt upgrade -y


============
#7zip
apt -y install p7zip-full
#curl -o /root/22092201.7z https://raw.githubusercontent.com/jxwdsb/xinwen/master/22092201.7z
#压缩
7z a -r webmanNeedFile.7z /root/webmanNeedFile

#7z a -r webman.7z /root/webman

cd /root
wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/22092201.7z
7z x 22092201.7z
cp -rf /root/22092201/webman/* /root/webman/
cp -rf /root/22092201/other/* /var/www/other/

rm -rf /root/22092201
rm -f /root/22092201.7z

#压缩文件夹
#tar zcvf nginx-$nginxVersion.tar.gz nginx
#tar zcvf php-$phpVersion.tar.gz php


============
#邮件服务器
#25,110,143,465,587,993,995,4190
#需要开放25端口
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


============
#装上 wrk 测试qbs
#https://www.cnblogs.com/quanxiaoha/p/10661650.html
cd /root
apt -y install build-essential libssl-dev git zip
git clone https://github.com/wg/wrk.git wrk
cd wrk
make -j72
cp wrk /usr/local/bin
#https://www.wkwkk.com/articles/9205c41e574c6321.html
apt -y install apache2-utils
ulimit -n 65535
#curl -o wrk.lua https://raw.githubusercontent.com/jxwdsb/xinwen/master/wrk.lua
#wrk -t256 -c65535 -d30s -s /root/wrk.lua https://api.jybeing.com/byhd/hdb/user_token_update.php
#wrk -t256 -c65535 -d30s --latency https://api.jybeing.com/byhd/hdb/user_token_update.php
#wrk -t256 -c65535 -d30s --latency https://demo.mineadmin.com/prod/
#wrk -t12 -c400 -d15s --latency https://demo.mineadmin.com/prod/

============
webman

链接pgsql
/root/webman/config/plugin/webman/medoo/database.php
,
	'pgsql' => [
		'type' => 'pgsql',
		'host' => 'localhost',
		'database' => 'postgres',
		'username' => 'postgres',
		'password' => 'postgres',
	],


============
php-fpm 控制上传文件大小
/etc/php/7.4/fpm/conf.d/1.ini

file_uploads = On
memory_limit = 128M
upload_max_filesize = 128M
post_max_size = 128M
max_execution_time = 600

============
pgsql
nextval('qaa'::regclass)
nextval('zz1'::regclass)
insert into "testABC" select generate_series(1,100000000);
DELETE FROM public."testABC";


============
磁盘扩容
fdisk -l
fdisk /dev/sda
d
n
p
1
y
w

e2fsck -f /dev/sda1 #检查分区信息
resize2fs /dev/sda1 #调整分区大小
df -h


============
nginx 开启软连接

ln -s /root/aria2-downloads /var/www/10.0.0.176/aria2-downloads

配置 nginx运行用户 www-data 改成 root
/etc/nginx/nginx.conf
#user www-data;
user root;

/etc/nginx/conf.d/10.0.0.176.new.conf
location  /aria2-downloads {
	charset utf-8;
	autoindex on;
	autoindex_exact_size off;
	autoindex_localtime on;
}


============


EOF