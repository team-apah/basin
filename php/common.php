<?php

function read_json_file($path) {
    $result = array();
    if (file_exists($path)) {
        $f = fopen($path, "r");
        $result = json_decode(fread($f, filesize($path)), true);
        fclose($f);
    }
    return $result;
}

function get_kw() {
    return array_merge(
        read_json_file("defaults.json"),
        read_json_file("data/config.json")
    );
}

function get_db($kw) {
    $db = new PDO(
        'mysql:host=localhost;dbname=' . $kw['DB_NAME'],
        $kw['DB_USERNAME'], $kw['DB_PASSWORD']
    );
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $db;
}

function lock($kw, &$db) {
    $s = $db->prepare('SELECT GET_LOCK(?, ?);');
    $s->execute(array($kw['LOCK_NAME'], $kw['LOCK_TIMEOUT']));
    return (bool) $s->fetch()[0];
}
function unlock($kw, &$db) {
    $s = $db->prepare('SELECT RELEASE_LOCK(?);');
    $s->execute(array($kw['LOCK_NAME']));
}

function check_qvalue(&$db, $qvalue) {
    $s = $db->prepare('SELECT status FROM Q_Values WHERE id = ?;');
    $s->setFetchMode(PDO::FETCH_NUM);
    $s->execute(array($qvalue));
    $result = $s->fetch();
    if ($result) {
        $s = $db->prepare('UPDATE Q_Values SET last_requested = NOW() WHERE id = ?;');
        $s->setFetchMode(PDO::FETCH_NUM);
        $s->execute(array($qvalue));
        return $result[0];
    }
    return false;
}

function queued(&$db) {
    $s = $db->prepare('SELECT count(id) FROM Queue;');
    $s->setFetchMode(PDO::FETCH_NUM);
    $s->execute();
    return (int) $s->fetch()[0];
}

function enqueue(&$db, $qvalue, $place = null) {
    if ($place === null) {
        $place = queued($db);
    }
    $s = $db->prepare(
        'INSERT INTO Q_Values VALUES (?, "QUEUED")' .
            'ON DUPLICATE KEY UPDATE status = "QUEUED";'
    );
    $s->execute(array($qvalue));
    $s = $db->prepare('INSERT INTO Queue VALUES (?, ?)');
    $s->execute(array($qvalue, $place));
}

function head(&$db) {
    $s = $db->prepare(
        'SELECT id FROM Queue WHERE place = 0;'
    );
    $s->execute();
    $result = $s->fetch();
    if ($result) {
        return $result[0];
    }
    return false;
}

function dequeue(&$db) {
    $head = head($db);
    if ($head) {
        $id = (int) $head;
        $s = $db->prepare(
            'DELETE FROM Queue WHERE id = ?;' .
            'UPDATE Q_Values SET status = "GENERATED" WHERE id = ?;' .
            'UPDATE Queue SET place = place - 1;'
        );
        $s->execute(array($id, $id));
        return $head;
    }
    return false;
}

function place_of(&$db, $qvalue) {
    $s = $db->prepare('SELECT place FROM Queue WHERE id = ?;');
    $s->setFetchMode(PDO::FETCH_NUM);
    $s->execute(array($qvalue));
    $result = $s->fetch();
    if ($result) {
        return $result[0];
    }
    return false;
}

function cached(&$db) {
    $s = $db->prepare('SELECT count(id) FROM Q_Values WHERE status = "GENERATED";');
    $s->setFetchMode(PDO::FETCH_NUM);
    $s->execute();
    return (int) $s->fetch()[0];
}

function oldest_request(&$db) {
    $s = $db->prepare('SELECT id FROM Q_Values WHERE status = "GENERATED" ORDER BY last_requested;');
    $s->setFetchMode(PDO::FETCH_NUM);
    $s->execute();
    $result = $s->fetch();
    if ($result) {
        return $result[0];
    }
    return false;
}

function forfeit(&$db, $q_value) {
    $id = (int) $q_value;
    $s = $db->prepare(
        'UPDATE Q_Values SET status = "FORFEITED" WHERE id = ?;' .
    );
    $s->execute(array($id));
}


?>
