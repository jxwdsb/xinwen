<?php
$vs = http_get('https://api.github.com/repos/phpmyadmin/phpmyadmin/tags?page=1&per_page=1');
$va = json_decode($vs, true);
$v = str_replace('RELEASE_','',$va[0]['name']);
$v = str_replace('_','.',$v);
echo $v;

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
