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

	public function sms_send(Request $request)
	{
		return json(['code' => 111, 'msg' => 'ok']);
	}
}