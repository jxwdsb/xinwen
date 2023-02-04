<?php
//0开始 第12个
$govs = http_get('https://api.github.com/repos/golang/go/tags?page=2&per_page=100');
//echo $govs;
$gova = json_decode($govs, true);
//echo $gova[12]['name'];

$v = '';
foreach ($gova as $key => $value) {
	if (is_bool(strpos($value['name'],'release')) && is_bool(strpos($value['name'],'beta')) && !strpos($value['name'],"rc") && !strpos($value['name'],"beta")) {
		//echo $value['name'] . "\n";
		$v = $value['name'];
		//只获取版本号 不做处理
		echo $v;exit();
		return false;
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
