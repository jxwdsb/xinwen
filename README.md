# xinwen
优雅一键部署 docker: mymariadb php-fpm nginx phpmyadmin 10秒钟建立网站环境<br> <br>
**_不支持openvz之类的vps 而且Linux内核应大于等于3.8_** <br> <br>
Debian 命令 【Debian 8 - 64 Bit /Debian 9 - 64 Bit 测试通过】   <br>
  ```
  apt-get install wget && wget -O test.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/test.sh && bash test.sh
  ```

  nginx 站点目录:/var/xinwen/www     
  nginx 配置文件:/var/xinwen/nginx   
  phpmyadmin http://yourip:8080/

docker pull 失败? 【docker 没问题的前提下】  <br>
如果是中国大陆 可以设置一下加速  <br>
```
apt-get install curl && curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://930e1f6b.m.daocloud.io -y
```
然后再执行修复命令  <br>
 ```
 wget -O test1.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/test1.sh && bash test1.sh
 ```
优雅一键Aria2 <br>
```
wget -O aria2.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/aria2.sh && bash aria2.sh
```
优雅一键SSR   <br>
```
wget -O ssr.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssr.sh && bash ssr.sh
```

服务器IP地址: yourip   <br>
远程端口: 你设置的端口 或 8887   <br>
密码: 你设置的密码   <br>
认证协议: auth_sha1_v4   <br>
混淆方式: http_simple   <br>
加密方法: chacha20    <br>
配置文件 /var/xinwen/ssr/shadowsocks.json   <br>
修改后请执行 `docker restart myssr` 或 `docker exec -i -t myssr /bin/bash -c '/etc/init.d/shadowsocks restart'`   <br>
用于重启shadowskcsR服务。<br><br>
感谢百度的一对一指导。
