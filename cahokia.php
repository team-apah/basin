<?php

# Urls
$GLOBALS['base_url'] = '/cahokia';
$GLOBALS['status_url'] = $GLOBALS['base_url'] . '/status.json';

# Paths
$GLOBALS['cahokia_path'] = dirname(__FILE__);
$GLOBALS['wotus_maps_path'] = $GLOBALS['cahokia_path'] . '/wotus_maps';
$GLOBALS['static_maps_path'] = $GLOBALS['cahokia_path'] . '/static_maps';
$GLOBALS['ready_path'] = $GLOBALS['cahokia_path'] . '/ready';

function directory_contents($path) {
	return array_values(array_diff(scandir($path), array('..', '.')));
}

function json($array) {
	header('Content-type: application/json');
	echo json_encode($array);
}

# Return System Status Array
function get_status() {
	$status = array();

	# Assume the system is "ready" if the 'ready' file exists
	$status['system_ready'] = file_exists($GLOBALS['ready_path']);

	# Return if the system isn't ready
	if (!$status['system_ready']) {
		return $status;
	}

	# Else check for map directories
	$status['system_error'] = !(
		file_exists($GLOBALS['wotus_maps_path'])
			&&
		file_exists($GLOBALS['static_maps_path'])
	);
	if ($status['system_error']) { # Return Error
		return $status;
	}

	# Return complete Status
	return $status;
}

function serve() {
	$url = $_SERVER['REQUEST_URI'];
    $valid = false;

    # Get Status and wotus values
    $status = get_status();
    $wotus_values = directory_contents($GLOBALS['wotus_maps_path']);

    if (!$status['system_ready'] || $status['system_error']) {
        $valid = true;
    }

	# Return Status
	if ($url == $GLOBALS['status_url']) {
        # Add available static maps to the state
        $status['static_maps'] = directory_contents($GLOBALS['static_maps_path']);
        $valid = true;
	}

	# Query about Wotus Value
	$rv = preg_match('/\/cahokia\/has\/(\\d+)/', $url, $matches);
	if ($rv) {
		$status['value'] = in_array($matches[1], $wotus_values);
        $valid = true;
	}
	
    if ($valid) {
        json($status);
    } else {
        http_response_code(404);
    }
}

serve();
?>
