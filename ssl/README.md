优雅配置ssl 自用 不适用所有人，需要你自己申请ssl证书 <br>
```
wget -O ssl_test.sh https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/ssl_test.sh && bash ssl_test.sh
```
配置文件 /var/xinwen/nginx/default.conf <br>
修改配置文件后 <br>
`docker exec -i -t mynginx /bin/bash -c 'nginx -s reload'` <br>
重载配置 或 <br>
`docker restart mynginx` <br>
