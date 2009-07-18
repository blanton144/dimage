<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Untitled Document</title>
</head>
<body>
<?php
	ini_set('display_errors',1);
	error_reporting(E_ALL|E_STRICT);
	$it = system("/usr/bin/swarp sdss-tmp/J125148.59+413246.5-clipped-u-192.721_41.1456388691.fits sdss-tmp/J125152.78+403658.5-clipped-u-192.721_41.0556387165.fits -IMAGEOUT_NAME=sdss-tmp/test.fits",$output);
	print_r($output);
	print_r($it);
?>
</body>
</html>