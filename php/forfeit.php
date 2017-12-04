<?php

include 'common.php';

$kw = get_kw();
$db = get_db($kw);

lock($kw, $db);
$q_value = oldest_request($db);
forfeit($db, $q_value);
unlock($kw, $db);
echo $value . "\n";

?>

