#!/bin/bash
#¨Docker 快速删除网站环境¨
#¨v: 0.0.1¨
#¨By: xinwen¨
echo ¨docker: del all¨
read -t 30 -n 1 -p "开始卸载吗?[y/n]:" start 
if [[ $start == "y" ]]; then
	echo
	#docker中 启动所有的容器命令
	#docker start $(docker ps -a | awk '{ print $1}' | tail -n +2)
	#docker中    关闭所有的容器命令
	docker stop $(docker ps -a | awk '{ print $1}' | tail -n +2)
	#docker中 删除所有的容器命令
	docker rm $(docker ps -a | awk '{ print $1}' | tail -n +2)
	#docker中    删除所有的镜像
	docker rmi $(docker images | awk '{print $3}' |tail -n +2)
	echo -e "\033[32m 卸载完成 \033[0m"
	cd /root
	exit 0
else
	echo 
	echo -e  "\033[31m 取消卸载 \033[0m"
	exit 0
fi 
