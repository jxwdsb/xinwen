<?php
	

namespace app\controller;

use support\Request;
use Webman\Medoo\Medoo;
use PDO;

class demo 
{

	public function test1()
	{
		//application/json
		//text/html;charset=utf-8
		return reJson();
	}

	public function test2()
	{
		$url = 'http://127.0.0.1:8787/demo/test1';
		$post_data = array(
			'a1' => 123,
			'a2' => 456,
		);
		return send_post($url, $post_data);
	}

	public function test3()
	{
		return alp_rand(99);
	}

	public function test4()
	{
		return Google2FA_URL(alp_rand(16), 'li', 'wai');
	}

	public function test5()
	{
		return Google2FA_QR($this::test4());
	}

	public function test6()
	{
		return '<img src="data:image/png;base64, ' . $this::test5() . '">';
	}

	public function test7()
	{
		return response()->file(public_path() . '/favicon.ico');
	}

	public function test8()
	{
		return response()->download(public_path() . '/repos.7z', 'repos.7z');
		return response()->download(public_path() . '/favicon.ico', 'favicon.ico');
	}

	public function test9()
	{
		// 创建图像
		$im = imagecreatetruecolor(120, 20);
		$text_color = imagecolorallocate($im, 233, 14, 91);
		imagestring($im, 1, 5, 5,  'A Simple Text String', $text_color);

		// 开始获取输出
		ob_start();
		// 输出图像
		imagejpeg($im);
		// 获得图像内容
		$image = ob_get_clean();

		// 发送图像
		return response($image)->header('Content-Type', 'image/jpeg');
	}

	public function test10()
	{
		$rows = Medoo::query('SELECT * FROM `global_priv`;',[])->fetchAll(PDO::FETCH_ASSOC);
		return reJson(0, $rows);
	}

	public function login(Request $request)
	{
		$row = Medoo::instance('demo')->query('SELECT userID, token FROM `user` WHERE `pn` = :pn AND `passwd` = :passwd;',[':pn' => $GLOBALS['pn'], ':passwd' => md5($GLOBALS['passwd']), ])->fetchAll(PDO::FETCH_ASSOC)[0];
		$userID = $row['userID'];
		$token = alp_rand();
		upToken($userID, $token);
		return reJson(0, ['token'=>$token]);
	}

	public function login1(Request $request)
	{
		return reJson(0, ['msg'=>'登录成功', ]);
	}

	public function upload(Request $request)
	{
		param_post($request, ['file']);
		foreach ($request->file() as $key => $spl_file) {
			var_export($spl_file->isValid());
			var_export("\n");
			var_export($spl_file->getUploadExtension()); // 上传文件后缀名，例如'jpg'
			var_export("\nmine类型");//可能假的
			var_export($spl_file->getUploadMineType()); // 上传文件mine类型，例如 'image/jpeg'
			var_export("\n错误码");
			var_export($spl_file->getUploadErrorCode()); // 获取上传错误码，例如 UPLOAD_ERR_NO_TMP_DIR UPLOAD_ERR_NO_FILE UPLOAD_ERR_CANT_WRITE
			var_export("\n文件名");
			var_export($spl_file->getUploadName()); // 上传文件名，例如 'my-test.jpg'
			var_export("\n大小");
			var_export($spl_file->getSize()); // 获得文件大小，例如 13364，单位字节
			var_export("\n目录");
			var_export($spl_file->getPath()); // 获得上传的目录，例如 '/tmp'
			var_export("\n路径");
			var_export($spl_file->getRealPath()); // 获得临时文件路径，例如 `/tmp/workerman.upload.SRliMu`
			var_export("\n");
			if (!$spl_file->getSize()) {
				var_export("\n跳过");
			} else {
				$new_route = "/var/www/other/files/" . $spl_file->getUploadName();
				var_export( rename($spl_file->getRealPath(), $new_route) );
				echo "\n" . mime_content_type($new_route); //真实mine类型
			}

		}
		//return reJson(0, ['msg'=>'上传成功', 'msg'=>$request->file(), ]);
	}

	public function getRoute(Request $request)
	{
		param_post($request, ['route']);
		return reJson(0, ['files'=>scandir('./public'.$GLOBALS['route'])]);
	}

}

