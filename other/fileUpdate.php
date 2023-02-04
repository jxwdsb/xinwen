<?php
	
/********
监控文件更新
cd /root/GitFiles/other && php fileUpdate.php
*/

function GitUpload()
{
	system('cd /root/GitFiles && git add -A && git commit -m "update robot '.time().'" && git push -u xinwen +main');
}

GitUpload();
echo "fileUpdate \n";

$fileInfo = array();

function fileShow($dir){//遍历目录下的所有文件和文件夹
	global $fileInfo;
	$handle = opendir($dir);
	while($file = readdir($handle)){
		if ($file !== '..' && $file !== '.'){
			$f = $dir.'/'.$file;
			if (is_file($f)){
				//是文件
				if (!isset($fileInfo[$f] )) {
					//没有设置
					$arr = array();
					$arr['time'] = filemtime($f);
					$arr['filesize'] = filesize($f);
					$fileInfo[$f] = $arr;
				} else {
					if ($fileInfo[$f]['time'] != filemtime($f)) {
						$fileInfo[$f]['time'] = filemtime($f);
						if (strpos($f, '/root/.') !== false) {
							//是隐藏文件 跳过
						} else if (strpos($f, '/root/GitFiles/.') !== false) {
							//是隐藏文件 跳过
						} else if (strpos($f, '/runtime/') !== false) {
							//是日志文件 跳过
						} else if (strpos($f, '/plugin/webman/gateway/') !== false) {
							echo "reload {$f} \n";
							system("cd /root/webman && php start.php reload");
						} else {
							echo "Git Upload {$f} \n";
							#必须得更新一次 记住github token
							GitUpload();
						}
						$fileInfo[$f]['filesize'] = filesize($f);
					}
				}
			} else {
				//是目录
				if (!isset($fileInfo[$dir])) {
					$fileInfo[$dir] = [
						'filecount' => exec("ls -a -l {$dir} | wc -l;"),
					];
				} else {
					$filecount = exec("ls -a -l {$dir} | wc -l;");
					if ($fileInfo[$dir]['filecount'] !== $filecount) {
						$fileInfo[$dir]['filecount'] = $filecount;
						echo "Git Upload Dir {$f} \n";
						GitUpload();
					}
				}
				fileShow($f);
			}
		}
	}
}

$arr = [
	'/root',
	//'/root/GitFiles/webman/plugin/webman/gateway/',
];
$c = count($arr);

while (true) {
	for ($i=0; $i < $c; $i++) { 
		fileShow($arr[$i]);
	}
	usleep(1000000);
}
