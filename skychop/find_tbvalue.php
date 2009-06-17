<?php
if (isset($_REQUEST['unitsDec'])) {
	$unitsDec = $_REQUEST['unitsDec'];
	switch($unitsDec) {
		case "degsDec" :
			echo "0.0000";
			break;
		case "hrsDec" :
			echo "00:00:00";
			break;
	}
}
elseif (isset($_REQUEST['unitsRA'])) {
	$unitsRA = $_REQUEST['unitsRA'];
	switch($unitsRA) {
		case "degsRA" :
			echo "0.0000";
			break;
		case "hrsRA" :
			echo "00:00:00";
			break;
	}
}

?>