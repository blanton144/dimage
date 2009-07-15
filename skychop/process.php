<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Untitled Document</title>
<?php
	// Get variables from form GET
	$RA = $_GET['ra'];
	$dec = $_GET['dec'];
	$sizeX = $_GET['xsize'];
	$sizeY = $_GET['ysize'];
	$bands = $_GET['bands'];
	$fname = stripslashes($_GET['fname']);
	
	// Other variable declarations
	$skychop = "/var/www/html/sdss3/skychop";
	
	/*
	print "RA = $RA";
	print "Dec = $dec";
	print "Bands = $bands";
	print "File name = $fname";
	*/
	
	$test = exec("/usr/local/epd/bin/python $skychop/test_js_timer.py > $skychop/sdss-tmp/$fname 2>&1 &");
	print "$test";
	
?>
</head>
<body>
</body>
</html>