<?php
	
namespace app\exception;

use Throwable;
use Webman\Http\Request;
use Webman\Http\Response;
use Webman\Medoo\Medoo;

class Handler extends \support\exception\Handler
{
	/**
	* 渲染返回
	* @param Request $request
	* @param Throwable $exception
	* @return Response
	*/
	public function render(Request $request, Throwable $exception) : Response
	{
		$re_code = $exception->getCode();
		var_dump($re_code);

		$msg = $exception->getMessage();
		var_dump($msg);
		
		if ($msg == 'true') {
			return json([
				'code' => $re_code, 
			]);
		}
		$traces = htmlspecialchars($exception);

		$count = Medoo::instance('test')->count('bug_traces', [
			'traces' => $traces,
		]);

		if ($count == 0) {
			Medoo::instance('test')->insert('bug_traces', [
				're_code' => $re_code,
				'msg' => $msg,
				'traces' => $traces,
				'time' => time(),
			]);
		}

		return json([
			'code' => 500, 
			'msg' => $msg,
		]);
		
		/*
		$code = $exception->getCode();
		// ajax请求返回json数据
		if ($request->expectsJson()) {
			return json(['code' => $code ? $code : 500, 'msg' => $exception->getMessage(), 'traces' => htmlspecialchars($exception) ]);
		}
		// 页面请求返回500.html模版
		return view('error', ['exception' => $exception]);
		*/
	}
}