<?php
	
namespace app\exception;

use Throwable;
use Webman\Http\Request;
use Webman\Http\Response;

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
		$code = $exception->getCode();
		// ajax请求返回json数据
		if ($request->expectsJson()) {
			return json(['code' => $code ? $code : 500, 'message' => $exception->getMessage(), 'traces' => htmlspecialchars($exception) ]);
		}
		// 页面请求返回500.html模版
		return view('error', ['exception' => $exception]);
	}
}