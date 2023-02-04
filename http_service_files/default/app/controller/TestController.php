<?php
	
namespace app\controller;

use support\Request;


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
		return json(['code' => 0, 'msg' => $data]);
	}

	public function sms_send(Request $request)
	{
		return json(['code' => 0, 'msg' => 'ok']);
	}
}