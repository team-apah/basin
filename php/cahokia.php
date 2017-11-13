<?php

include 'common.php';

function json($array) {
	header('Content-type: application/json');
	echo json_encode($array);
}

function process_qvalue($kw, $url, &$rc, &$status, $qvalue) {
    $db = get_db($kw);
    if (lock($kw, $db)) {
        $qstatus = check_qvalue($db, $qvalue);
        if ($qstatus == "GENERATED") { # Already Generated
            $status['generated'] = true;
        } else  {
            $rc = 202; # Accepted, being generated
            $status['generated'] = false;
                $queued = queued($db);
                if ($qstatus == "QUEUED") { # Queued, Just get Place
                    $status['queued'] = $queued;
                    $status['place'] = place_of($db, $qvalue) + 1;
                } else { # Need to queue
                    $status['queued'] = $queued + 1;
                    $status['place'] = $queued + 1;
                    enqueue($db, $qvalue, $queued);
                }
        }
        unlock($kw, $db);
    } else {
        $rc = 500;
        $status['failure'] = "lock";
    }
}

function serve($kw) {
	$url = $_SERVER['REQUEST_URI'];
    $valid = false;
    $rc = 200; # "OK"
    $status = array();

    # Process URL
    if ($url == "/". $kw['BASE_URL'] . "/status") { # Return Status
        $valid = true;
        try {
            $db = get_db($kw);
            $status['queued'] = queued($db);
        } catch (PDOException $e) { 
            $rc = 500;
            $status['failure'] = "database";
        }
	} else { # Query about Wotus Value or Invalid URL
        $rv = preg_match(
            "/\/" . $kw['BASE_URL'] . "\/wotus\/(\\d+)/",
            $url, $matches
        );
        if ($rv) {
            $valid = true;
            process_qvalue($kw, $url, $rc, $status, $matches[1]);
        }
    }
	
    # Validity
    if ($valid) {
        $status['valid_request'] = true;
    } else {
        $status['valid_request'] = false;
        $rc = 400; # Bad Request
    }

    # Return JSON Status
    json($status);
    http_response_code($rc);
}

chdir('..');
serve(get_kw());

?>
