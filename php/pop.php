<?php

include 'common.php';

$kw = get_kw();
$db = get_db($kw);

$db = get_db($kw);
if (!lock($kw, $db)) {
    exit(1);
}
dequeue($db);
unlock($kw, $db);

?>
