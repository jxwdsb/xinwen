<?php
	
namespace app\controller;
use PragmaRX\Google2FA\Google2FA;
use BaconQrCode\Renderer\ImageRenderer;
use BaconQrCode\Renderer\Image\ImagickImageBackEnd;
use BaconQrCode\Renderer\RendererStyle\RendererStyle;
use BaconQrCode\Writer;
use Webman\Medoo\Medoo;
use PDO;

function reJson($reCode=0, $str1='')
{

	$response = response();
	$response->header('Content-Type', 'application/json');
	switch ($reCode) {
		case 0:
			if ($str1 == '' ) {
				$response->withBody(json_encode(array('reCode' => 0 ), JSON_UNESCAPED_UNICODE));
			} else {
				$response->withBody(json_encode(array('reCode' => 0, 'data' => $str1 ), JSON_UNESCAPED_UNICODE));
			}
			break;
		case 1:
			$response->withBody(json_encode(array('reCode' => 1, 'message' => '数据库出现错误' ), JSON_UNESCAPED_UNICODE));
			break;
		case 2:
			$response->withBody(json_encode(array('reCode' => 2, 'message' => '缺少参数' ), JSON_UNESCAPED_UNICODE));
			break;
		case 3:
			$response->withBody(json_encode(array('reCode' => 3, 'message' => '账号验证失败' ), JSON_UNESCAPED_UNICODE));
			break;
		case 9:
			$response->withBody(json_encode(array('reCode' => 9, 'message' => $str1 ), JSON_UNESCAPED_UNICODE));
			break;
		
		default:
			$response->withBody(json_encode(array('reCode' => 9, 'message' => '出现未知错误' ), JSON_UNESCAPED_UNICODE));
			break;
	}
	return $response;
}


function send_post($url, $post_data)
{
	//send_post($url, $post_data);
	$postdata = http_build_query($post_data);
	$options = array(
		'http' => array(
			'method' => 'POST',
			'header' => 'Content-type:application/x-www-form-urlencoded',
			'content' => $postdata,
			'timeout' => 1 * 60 // 超时时间（单位:s）
		)
	);
	$context = stream_context_create($options);
	$result = file_get_contents($url, false, $context);
	return $result;
}

function alp_rand($size=32)//alphabet
{
	$reStr = '';
	for ($i = 0; $i < $size; $i++) {
		$reStr .= chr(mt_rand(65, 90));//97~122是小写的英文字母65~90是大写的
	}
	return $reStr;
}

function upToken($userID, $token)
{
	if (Medoo::instance('demo')->query('UPDATE `user` SET `token` = :token WHERE `user`.`userID` = :userID;',[':userID' => $userID, ':token' => $token, ])) {
	} else {
		throw new Exception('后端故障, 更新token 故障',9);
	}
}

function param_get($request, $arr, $bool=true)
{
	$c = count($arr);
	for ($i=0; $i < $c; $i++) {
		if ($request->get($arr[$i], '') == '') {
			if ($bool) {
				return false;
			} else {
				return reJson(2);
			}
		}
	}
	foreach ($arr as $key => $value) {
		$GLOBALS[$value] = $request->post($value, '');
	}
	return true;
}

function param_post($request, $arr) //parameter 
{
	$c = count($arr);
	for ($i=0; $i < $c; $i++) {
		if ($request->post($arr[$i], '') == '') {
			//throw new Exception('错误了',333);
		}
	}
	foreach ($arr as $key => $value) {
		$GLOBALS[$value] = $request->post($value, '');
	}
	return true;
}

function param_postA()
{
	//throw new Exception(json_encode(['reCode'=>20]));
	throw new Exception('错误了',333);
}

function Google2FA_URL($secretKey, $li='', $wai='' )
{
	$google2fa = new Google2FA();
	$qrCodeUrl = $google2fa->getQRCodeUrl(
		$wai,
		$li,
		$secretKey
	);
	return $qrCodeUrl;
}

function Google2FA_QR($link, $size=200)
{
	$writer = new Writer(
		new ImageRenderer(
			new RendererStyle($size),
			new ImagickImageBackEnd()
		)
	);
	$qrcode_image = base64_encode($writer->writeString($link));
	return $qrcode_image;
}

function Google2FA_Bool($secret, $secretKey)
{
	//secretKey 十六位大写
	$google2fa = new Google2FA();
	$window = 8;// 8 keys (respectively 4 minutes) past and future
	$valid = $google2fa->verifyKey($secretKey, $secret, $window);
	//return gettype($valid);//boolean
	return $valid;
}

function GetPage($tableName, $page=1, $count=20, $arr=[], $field='', $sort='DESC')
{
	//SELECT `name`, `help_category_id`, `description`, `example`, `url` FROM `help_topic` ORDER BY `help_topic_id` DESC
	//SELECT `help_topic_id`, `name`, `help_category_id`, `description`, `example`, `url` FROM `help_topic` ORDER BY `help_topic_id` DESC LIMIT 1, 5;
	//SELECT `help_topic_id`, `name`, `help_category_id`, `description`, `example`, `url` FROM `help_topic` ORDER BY `help_topic_id` ASC LIMIT 0, 5;
	if ($sort != 'ASC' && $sort != 'DESC') {
		return false;
	} else {
		if ($arr == []) {
			$arrS = '*';
		} else {
			$arrS = '';
			$arrC = count($arr);
			for ($i=0; $i < $arrC; $i++) {
				if ($i == 0) {
					$arrS = '`'.$arr[$i].'`';
				} else {
					$arrS = $arrS . ', `'.$arr[$i].'`';
				}
			}
		}
		$page = ($page - 1) * $count;
		$rows = Medoo::query('SELECT :arrS FROM `:tableName` ORDER BY `:field` ASC LIMIT :page, :count;',[':arrS' => $arrS, ':tableName' => $tableName, ':field' => $field, ':page' => $page, ':count' => $count, ])->fetchAll(PDO::FETCH_ASSOC);
	}
}
