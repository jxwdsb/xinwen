<?php
	
use Webman\Medoo\Medoo;
use \Jxwdsb\Xinwen\Exception\BaseException;

function sql_count($table, $where=[], $exit=[])
{
	echo "sql_count";
		throw new xwException('true', ['qqq','bbb']);
	$count = Medoo::instance('test')->count($table, $where);
	if ($count === 0 && $exit === []) {
		//throw new BaseException('true');
	} else {
		return $count;
	}
}

function sql_select($table, $columns='*', $where=[])
{
	return Medoo::instance('test')->select($table, $columns);
}

function sql_update($table, $data, $where=[])
{
	//更新数据库 判断是不是需要放入 redis
}

function sql_get()
{
	//
}

function redis_get()
{
	//
}

function redis_set()
{
	//
}

