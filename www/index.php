<?php
phpinfo();
//exit();
try {
    $con = new PDO('mysql:host=mymariadb;dbname=mysql', 'root', 'root');
    $con->query('SET NAMES UTF8');
    $res =  $con->query('SELECT * FROM `time_zone`');
    while ($row = $res->fetch(PDO::FETCH_ASSOC)) {
        echo "id:{$row['Time_zone_id']} name:{$row['Use_leap_seconds']}";
    }
} catch (PDOException $e) {
     echo '错误原因：'  . $e->getMessage();
}
