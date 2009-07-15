<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Processing Data...</title>
<link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
<center><font class="theLabels">Your request is pending, please be patient.<br /> Depending on the size of the image requested, this could take some time.</font></center>
<?php
	$skychop = "/var/www/html/sdss3/skychop";
	$RA = $_GET['ra'];
	$dec = $_GET['dec'];
	$sizeX = $_GET['xsize'];
	$sizeY = $_GET['ysize'];
	$bands = $_GET['bands'];
	$fname = $_GET['fname'];
	$pysuccess = exec("/usr/local/epd/bin/python $skychop/find_image.py $RA $dec $sizeX $sizeY $bands $fname 2>&1",$output);
	if ($pysuccess == 1) {
		print "<center><a href='sdss-tmp/$fname.tar.gz'>Download Files</a></center>";
		print "<center><font class='notifyText'>Your session ID is: <b>$fname</b>. <br /> You can come back any time within 30 minutes to re-download the files.</font></center>";	
	}
	else {
		print "<font class='errorText'><center>An unknown error has occurred.</center></font>";
		print_r($output);
	}
	
	/*
	print_r($_SESSION);
	$skychop = $_SESSION['skychop'];
	$fname = $_SESSION['fname'];
	if (!(isset($script_start))) {
		$test = exec("/usr/local/epd/bin/python $skychop/test_js_timer.py 2>&1 &");
		$script_start = 1;
	}
	if ($_GET['processing'] == 1) {
		sleep(5);
		$openfile = fopen("$skychop/sdss-tmp/testfile.txt","r") or exit("Unable to open file!");
		$line = fgets($openfile);
		fclose($openfile);
		echo($line);
	}
	$site = "process.php?processing=1";
	echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
	//}
	if ($new_line != "0") {
		$site = "process.php?processing=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');	
	}
	else {
		$site = "process.php?processing=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');	
	}*/
?>
</body>
</html>