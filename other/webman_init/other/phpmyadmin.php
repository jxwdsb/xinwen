<?php

$vs = http_get('https://api.github.com/repos/phpmyadmin/phpmyadmin/tags?page=1&per_page=1');
$va = json_decode($vs, true);
$v = str_replace('RELEASE_','',$va[0]['name']);
$v = str_replace('_','.',$v);

$file_name = '/root/GitFiles/other/phpmyadmin/package.json';
if (file_exists($file_name)) {
	if (json_decode(file_get_contents($file_name), true)['version'] != $v) {
		echo $v;
		/*
		if(file_put_contents($file_name,file_get_contents($url))) {
			echo "文件下载成功";
		} else {
			echo "文件下载失败";
		}
		*/
	} else {
		echo 'noUp';
	}
}

function http_get($url, $header = [], $proxy = [])
{
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_USERAGENT,'nldzz');
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	if (!empty($header)) {
		curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
	}
	if (!empty($proxy)) {
		curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5);
		curl_setopt($ch, CURLOPT_PROXY, "{$proxy['ip']}:{$proxy['port']}");
		curl_setopt($ch, CURLOPT_PROXYUSERPWD, "{$proxy['username']}:{$proxy['password']}");
	}
	$result = curl_exec($ch);
	curl_close($ch);

	return $result;
}
