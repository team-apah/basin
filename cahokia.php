<?php
# Urls
$GLOBALS['base_url'] = '/cahokia';
$GLOBALS['status_url'] = $GLOBALS['base_url'] . '/status';

# Paths
$GLOBALS['cahokia_path'] = dirname(__FILE__) . '/data';
$GLOBALS['ready_path'] = $GLOBALS['cahokia_path'] . '/ready';
$GLOBALS['completed_path'] = $GLOBALS['cahokia_path'] . '/completed';

function directory_contents($path) {
	return array_values(array_diff(scandir($path), array('..', '.')));
}

function json($array) {
	header('Content-type: application/json');
	echo json_encode($array);
}

# Return System Status Array
function get_status() {
	# Assume the system is "ready" if the 'ready' file exists
	$status['system_ready'] = file_exists($GLOBALS['ready_path']);

	# Return complete Status
	return $status;
}

function serve() {
	$url = $_SERVER['REQUEST_URI'];
    $valid = false;
    $response_code = 200; # "OK"

    # Get Status
    $status = get_status();
    
    # Process URL
    if ($url == $GLOBALS['status_url']) { # Return Status
        # Add available static maps to the state
        $valid = true;
	} else { # Query about Wotus Value or Invalid URL
        $rv = preg_match('/\/cahokia\/wotus\/(\\d+)/', $url, $matches);
        if ($rv) {
            $valid = true;
            exec("grep '^" . $matches[1] . "$' " . $GLOBALS['completed_path'], $exec_output, $grep_rv);
            if ($grep_rv) { // Value has not been generated
                $status['generated'] = false;
                exec("./queue add " . $matches[1], $exec_output, $queue_rv);
                if ($queue_rv == 0 || $queue_rv == 10) {
                    $response_code = 202; # Accepted, needs to be generated
                } else {
                    $response_code = 500; # Internal Error
                }
            } else {
                $status['generated'] = true;
            }
        }
    }
	
    # Validity
    if ($valid) {
        $status['valid_request'] = true;
    } else {
        $status['valid_request'] = false;
        $response_code = 400; # Bad Request
    }

    # Return JSON Status
    json($status);
    http_response_code($response_code);
}

serve();
?>
