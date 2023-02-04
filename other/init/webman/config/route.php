<?php
	
use support\Request;
use Webman\Route;

Route::fallback(function(Request $request){
    return json(['reCode' => 404, 'message' => '404 not found']);
    /*
	if ($request->expectsJson()) {
		return json(['reCode' => 404, 'message' => '404 not found']);
	}
	return view('404', ['error' => 'some error']);
    */
});