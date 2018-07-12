优雅配置ssl 自用 不适用所有人，需要你自己申请ssl证书 <br>
```
cd /var/xinwen && wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/sslforfree.zip && 7z x sslforfree.zip -r -o/var/xinwen/nginx -y && cd /var/xinwen/nginx && wget https://raw.githubusercontent.com/jxwdsb/xinwen/master/ssl/nldzz.conf && docker restart mynginx
```
