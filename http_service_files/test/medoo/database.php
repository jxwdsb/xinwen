<?php
return [
	'default' => [
		'type' => 'mysql',
		'host' => 'localhost',
		'database' => 'database',
		'username' => 'username',
		'password' => 'password',
		'charset' => 'utf8mb4',
		'collation' => 'utf8mb4_general_ci',
		'port' => 3306,
		'prefix' => '',
		'logging' => false,
		'error' => PDO::ERRMODE_EXCEPTION,
		'option' => [
			PDO::ATTR_CASE => PDO::CASE_NATURAL
		],
		'command' => [
			'SET SQL_MODE=ANSI_QUOTES'
		]
	],
	'xinwen' => [
		'type' => 'mysql',
		'host' => '127.0.0.1',
		'database' => 'xinwen',
		'username' => 'root',
		'password' => 'root',
		'charset' => 'utf8mb4',
		'collation' => 'utf8mb4_general_ci',
		'port' => 3306,
		'prefix' => '',
		'logging' => false,
		'error' => PDO::ERRMODE_EXCEPTION,
		'option' => [
			PDO::ATTR_CASE => PDO::CASE_NATURAL
		],
		'command' => [
			'SET SQL_MODE=ANSI_QUOTES'
		]
	],
	'test' => [
		'type' => 'mysql',
		'host' => '127.0.0.1',
		'database' => 'test',
		'username' => 'root',
		'password' => 'root',
		'charset' => 'utf8mb4',
		'collation' => 'utf8mb4_general_ci',
		'port' => 3306,
		'prefix' => '',
		'logging' => false,
		'error' => PDO::ERRMODE_EXCEPTION,
		'option' => [
			PDO::ATTR_CASE => PDO::CASE_NATURAL
		],
		'command' => [
			'SET SQL_MODE=ANSI_QUOTES'
		]
	],
];