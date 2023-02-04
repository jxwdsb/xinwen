<?php
	
namespace app\controller;

use support\Request;
use Webman\Medoo\Medoo;

class TestController
{
	function __construct()
	{
		//
	}

	public function index(Request $request)
	{
		return json(['code' => 0, 'msg' => 'ok']);
	}

	public function test(Request $request)
	{
		$data = Medoo::instance('test')->select('user', [
			'id',
			'token',
		], [
			'id' => 1,
		]);

		$count = Medoo::instance('test')->count('user', [
			'id' => 1,
		]);

		$count = Medoo::instance('test')->count('user', []);

		$sss = [];
		$count = Medoo::instance('test')->count('user', $sss);
		
		$data = Medoo::instance('test')->select('user', [
			'id',
			'token',
		], $sss);

		return json(['code' => 0, 'msg' => $data]);
	}

	public function sms_send(Request $request)
	{
		return json(['code' => 0, 'msg' => 'ok']);
	}
}