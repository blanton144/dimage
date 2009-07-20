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
	ini_set("display_errors","2");
	ERROR_REPORTING(E_ALL);
	$proc = $_GET['proc'];
	$skychop = "/var/www/html/sdss3/skychop";
	$RA = $_GET['ra'];
	$dec = $_GET['dec'];
	$sizeX = $_GET['xsize'];
	$sizeY = $_GET['ysize'];
	$bands = $_GET['bands'];
	$fname = $_GET['fname'];
	$tar_files = "";
	
	if ($proc == 1) {
		$filesToRmv = array(0 => "/var/www/html/sdss3/skychop/sdss-tmp/weight.fits");
		$pysuccess = exec("/usr/local/epd/bin/python $skychop/find_image.py $RA $dec $sizeX $sizeY $bands $fname 2>&1",$output);
		for ($i = 0; $i < strlen($bands); $i++) {
			$swarp = "swarp " . $output[$i * 2];
			$outpu = system($swarp . " 2>&1",$swarpout);
			print_r($swarpout);
			//print "$swarp";
			$tar_files .= $output[($i * 2) +1];
			$filesToRmv[] = "/var/www/html/sdss3/skychop/" . $output[($i * 2) +1];
		}

		exec("tar -cvvf sdss-tmp/$fname.tar $tar_files");
		exec("gzip -c sdss-tmp/$fname.tar > sdss-tmp/$fname.tar.gz");
		chmod("sdss-tmp/$fname.tar.gz",0777);
		
		// Clean Up
		//unlink("/var/www/html/sdss3/skychop/sdss-tmp/$fname.tar");
		//unlink($filesToRmv);
		if ($pysuccess == 1) {
			print "<center><a href='sdss-tmp/$fname.tar.gz'>Download Files</a></center>";
			print "<center><font class='notifyText'>Your session ID is: <b>$fname</b>. <br /> You can come back any time within 30 minutes to re-download the files.</font></center>";	
			print "<center><br /><a href='index.php'>Click to make another request</a></center>";
		}
		else {
			print "<font class='errorText'><center>An unknown error has occurred.</center></font>";
		}
	}
	else {
		$site = "process.php?ra=$RA&dec=$dec&xsize=$sizeX&ysize=$sizeY&bands=$bands&fname=$fname&proc=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
	}
?>
</body>
</html>