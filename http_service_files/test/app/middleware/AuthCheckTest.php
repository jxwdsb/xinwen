<?php
	
namespace app\middleware;

use Webman\MiddlewareInterface;
use Webman\Http\Response;
use Webman\Http\Request;
use Webman\Medoo\Medoo;
use PDO;

class AuthCheckTest implements MiddlewareInterface
{ 
	public function process(Request $request, callable $handler) : Response
	{
		if ($request->controller == 'app\controller\TestController') {
			switch ($request->action) {
				case 'login':

					$a = $request->post('pn');
					if (is_null($request->post('pn')) ) {
							return json(['reCode'=>2, 'message'=>'nulla']);
						echo "nulla";
					} else {
						echo "存在";
							return json(['reCode'=>2, 'message'=>'存在']);
					}
					
					var_dump($a);
					
					//判断账号密码登录
					$arr = ['pn', 'passwd'];
					$c = count($arr);
					for ($i=0; $i < $c; $i++) {
						if ($request->post($arr[$i], '') == '') {
							return json(['reCode'=>2, 'message'=>'缺少参数']);
						}
					}
					foreach ($arr as $key => $value) {
						${$value} = $request->post($value, '');
						$GLOBALS[$value] = ${$value};
					}
					if (Medoo::instance('demo')->query('SELECT count(*) FROM `user` WHERE `pn` = :pn AND `passwd` = :passwd;',[':pn' => $pn, ':passwd' => md5($passwd), ])->fetchAll(PDO::FETCH_ASSOC)[0]['count(*)'] != 1) {
						//登录失败 多次失败建议提交网关处理
						return json(['reCode'=>3, 'message'=>'账号验证失败']);
					}
					break;
				
				default:
					//判断userID token
					$arr = ['userID', 'token'];
					$c = count($arr);
					for ($i=0; $i < $c; $i++) {
						if ($request->post($arr[$i], '') == '') {
							return json(['reCode'=>2, 'message'=>'缺少参数']);
						}
					}
					foreach ($arr as $key => $value) {
						${$value} = $request->post($value, '');
						$GLOBALS[$value] = ${$value};
					}
					if (Medoo::instance('demo')->query('SELECT count(*) FROM `user` WHERE `userID` = :userID AND `token` = :token;',[':userID' => $userID, ':token' => $token, ])->fetchAll(PDO::FETCH_ASSOC)[0]['count(*)'] != 1) {
						//登录失败 多次失败建议提交网关处理
						return json(['reCode'=>3, 'message'=>'账号验证失败']);
					}
					break;
			}
		} else {
			//
		}
		
		return $handler($request);
	}
}