#
echo ¨html: aria2-WebUi¨
read -t 30 -n 1 -p "开始布置吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	echo -e "\033[32m 开始布置 \033[0m"
	#开始执行
	cd /var/xinwen/www
	wget -O webui-aria2-master.zip https://codeload.github.com/ziahamza/webui-aria2/zip/master  
	7z x webui-aria2-master.zip -r -o/var/xinwen/www -y 
	mv ./webui-aria2-master ./aria2ui 
	chmod -R 755 ./aria2ui 
	rm webui-aria2-master.zip
	echo -e "\033[32m 布置完成 \033[0m"
	echo -e "\033[32m nginx 站点:https://yourip/aria2ui \033[0m"
	echo -e "\033[32m nginx 作者:Github.com ziahamza/webui-aria2 \033[0m"
	cd /root
	exit 0
else
	echo 
	echo -e  "\033[31m 取消布置 \033[0m"
	exit 0
fi 