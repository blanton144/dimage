<?php
	// Get variables from form GET
	ini_Set('display_errors',1); // turn on error reporting while developing
	error_reporting(E_ALL & ~E_NOTICE);
	if (!(isset($_SESSION))) {
		session_start();
		$_SESSION['RA'] = $_GET['ra'];
		$_SESSION['dec'] = $_GET['dec'];
		$_SESSION['sizeX'] = $_GET['xsize'];
		$_SESSION['sizeY'] = $_GET['ysize'];
		$_SESSION['bands'] = $_GET['bands'];
		$_SESSION['fname'] = stripslashes($_GET['fname']);
		$_SESSION['skychop'] = "/var/www/html/sdss3/skychop";
	}
	
	function wait_get_line($file,$dir) {
		sleep(5);
		$openfile = fopen("$dir$file.txt","r") or exit("Unable to open file!");
		$line = fgets($openfile);
		fclose($openfile);
		return ($line);
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Untitled Document</title>
</head>
<body>
<?php
	$skychop = $_SESSION['skychop'];
	$fname = $_SESSION['fname'];
	if (!(isset($script_start))) {
		$test = exec("/usr/local/epd/bin/python $skychop/test_js_timer.py > $skychop/sdss-tmp/$fname.txt 2>&1 &");
		$script_start = 1;
	}
	if ($_GET['processing'] == 1) {
		$new_line = wait_get_line($fname,"$skychop/sdss-tmp/");
	}
	print "$new_line";
	
	if ($new_line != "0") {
		$site = "process.php?processing=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');	
	}
	else {
		$site = "process.php?processing=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');	
	}
?>
</body>
</html>