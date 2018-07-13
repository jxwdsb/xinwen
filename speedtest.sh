#!/bin/sh   
##########################
echo "正在为你安装相关依赖，可能需要一分钟"
#懒得做判断干脆redhat&debian一窝端
yum install wget ca-certificates python -y>/dev/null 2>&1
apt-get install wget ca-certificates python -y >/dev/null 2>&1
#==========================================================
#修补bug2.0，直接删除PY执行文件
rm -rf speedtest.py
#下载PY执行文件
wget https://raw.github.com/sivel/speedtest-cli/master/speedtest.py
chmod a+rx speedtest.py
sed -i '1805,1806d' speedtest.py 
#==========================================================
MSG_MAIN_MENU="
欢迎使用 speedtest.net 国内节点手动测试脚本.
====================================================
由xu1s.win制作。由wxlost发布
====================================================
speedtest源码：https://github.com/sivel/speedtest-cli 
====================================================
选择服务器想测试的节点.<失效节点多,建议测试多个节点>
====================================================
1. 本地节点；2.深圳电信：3.上海电信多线：4.成都电信：5.北京电信；6.杭州电信：7.北京联通：8.北京移动：9.西安移动：10.南京联通：11.广州移动
====================================================
12.重庆移动：13.重庆电信：14.南宁电信：15.合肥电信：16.合肥联通：17.武汉电信：18.南昌电信：19.长沙电信：20.上海联通：
====================================================
请输入对应的数字："
#==========================================================
	
# 显示主菜单
echo -n "$MSG_MAIN_MENU"
	read flag
	echo ""
	curl myip.ipip.net
	case $flag in
		1)
			  python speedtest.py
			  ;;
		2)
		      python speedtest.py --server 5081
			  ;;
		3)
			  python speedtest.py --server 17019
			  ;;
		4)
			  python speedtest.py --server 4624
			  ;;
		5)
			  python speedtest.py --server 4751
			  ;;
		6)
			  python speedtest.py --server 7509
			  ;;
		7)  
		      python speedtest.py --server 5145
			  ;;
		8)
			  python speedtest.py --server 4713
			  ;;
		9)
			  python speedtest.py --server 5292
			  ;;
		10)
			  python speedtest.py --server 13704
			  ;;	
		11)
			  python speedtest.py --server 6611
			  ;;		  
		12)
			  python speedtest.py --server 16409
			  ;;	
		13)
			  python speedtest.py --server 16983
			  ;;
		14)
			  python speedtest.py --server 10305
			  ;; 
		15)
			  python speedtest.py --server 17145
			  ;; 	  
		16)
			  python speedtest.py --server 5724
			  ;; 
		17)
			  python speedtest.py --server 5485
			  ;; 	  
		18)
			  python speedtest.py --server 16399
			  ;; 
		19)
			  python speedtest.py --server 6132
			  ;; 	
		20)
			  python speedtest.py --server 5083
			  ;; 	  
	esac	