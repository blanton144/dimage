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
	$it = system("ulimit -a",$output);
	print_r($output);
	print_r($it);
?>
</body>
</html>