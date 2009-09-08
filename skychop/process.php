<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Processing Data...</title>
<link href="style.css" rel="stylesheet" type="text/css">
</head>
<body><br /><br />
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
	$thumb = $_GET['thumb'];
	$thumbYN = $_GET['tyn'];
	$tar_files = "";
	
	if ($proc == 1) {
		chdir("/var/www/html/sdss3/skychop/sdss-tmp/");	
		$filesToRmv = array(0 => "/var/www/html/sdss3/skychop/sdss-tmp/weight.fits");
		$py = exec("/usr/local/epd/bin/python $skychop/find_image.py $RA $dec $sizeX $sizeY $bands $fname 2>&1",$output);
		
		for ($i = 0; $i < strlen($bands); $i++) {
			$swarp = "swarp " . $output[$i * 2];
			$outpu = system($swarp,$swarpout);
			//print_r($swarpout);
			//print "$outpu";
			$tar_files .= " " . $output[($i * 2) +1];
			$to_clip_again[] = $output[($i * 2) +1];
			$filesToRmv[] = "/var/www/html/sdss3/skychop/sdss-tmp/" . $output[($i * 2) +1];
			if ($bands[$i] == $thumb && $thumbYN == 1) {
				$im = $output[($i * 2) +1];
			}
		}
		
		foreach ($to_clip_again as $im_to_clip) {
			$pyy = exec("/usr/local/epd/bin/python $skychop/clipfits.py $skychop/sdss-tmp $im_to_clip $RA $dec $sizeX $sizeY $im_to_clip 2>&1");
			print "$pyy";
		}
		
		if ($thumbYN == 1) {
			exec("/usr/local/epd/bin/python $skychop/fitstograyscale.py $im $fname", $thumbName);
		}
		print_r($thumbName);
		print_r($thumbName[0]);
		exec("tar -cvvf $skychop/sdss-tmp/$fname.tar $tar_files");
		exec("gzip -c $skychop/sdss-tmp/$fname.tar > $skychop/sdss-tmp/$fname.tar.gz");
		chmod("$skychop/sdss-tmp/$fname.tar.gz",0777);
		//print_r($filesToRmv);
		// Clean Up
		unlink("/var/www/html/sdss3/skychop/sdss-tmp/$fname.tar");
		foreach ($filesToRmv as $f) {
			unlink($f);
		}
		
		if (file_exists("/var/www/html/sdss3/skychop/sdss-tmp/$fname.tar.gz")) {
			print "<center><a href='sdss-tmp/$fname.tar.gz'>Download Files</a></center>";
			print "<center><font class='notifyText'>Your session ID is: <b>$fname</b>. <br /> You can come back any time within 30 minutes to re-download the files.</font></center>";	
			print "<center><br /><a href='index.php'>Click to make another request</a></center>";
			if ($thumbYN == 1) {
				print "<br /><center><img src='sdss-tmp/$thumbName[0]'></center>";
			}
		}
		else {
			print "<font class='errorText'><center>An unknown error has occurred.</center></font>";
		}
	}
	else {
		$site = "process.php?ra=$RA&dec=$dec&xsize=$sizeX&ysize=$sizeY&bands=$bands&fname=$fname&thumb=$thumb&tyn=$thumbYN&proc=1";
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
	}
?>
</body>
</html>