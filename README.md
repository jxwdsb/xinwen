# xinwen
优雅一键部署 docker: mymariadb php-fpm nginx phpmyadmin
10秒钟建立网站环境

Debian 命令 【Debian 8 - 64 Bit 测试通过】  
apt-get install wget && wget -O test.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/test.sh && bash test.sh

  nginx 站点目录:/var/xinwen/www 
  nginx 配置文件:/var/xinwen/nginx 
  phpmyadmin http://yourip:8080/

docker pull 失败? 【docker 没问题的前提下】  
如果是中国大陆 可以设置一下加速  
	apt-get install curl && curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://930e1f6b.m.daocloud.io -y
然后再执行修复命令  
	wget -O test1.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/test1.sh && bash test1.sh
