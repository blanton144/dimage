<?php
	// Get variables from form GET
	if (isset($_SESSION)) {
		continue;
	}
	else {
		session_start();
		$_SESSION['RA'] = $_GET['ra'];
		$_SESSION['dec'] = $_GET['dec'];
		$_SESSION['sizeX'] = $_GET['xsize'];
		$_SESSION['sizeY'] = $_GET['ysize'];
		$_SESSION['bands'] = $_GET['bands'];
		$_SESSION['fname'] = stripslashes($_GET['fname']);
		$_SESSION['skychop'] = "/var/www/html/sdss3/skychop";
	}
	ini_Set('display_errors',1); // turn on error reporting while developing
	
	function wait_get_line($file) {
		sleep(5);
		$openfile = fopen("sdss-tmp/$file","r");
		$line = fread($openfile, 1024);
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
	print "Hello, world!";
	if (isset($script_start)) {
		continue;
	}
	else {
		$test = exec("/usr/local/epd/bin/python $skychop/test_js_timer.py > $skychop/sdss-tmp/$fname 2>&1 &");
		$script_start = 1;
		print "run script";
	}
	
	$new_line = wait_get_line("$_SESSION['fname']");
	
	if ($new_line != 0) {
		print "$new_line";
		$site = "process.php?processing=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');	
	}
	else {
		print "Finished";
	}
	
?>
</body>
</html>