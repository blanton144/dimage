<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Convert</title>
<?php
if (isset($_POST['submit'])) {
	$decDeg = $_POST['hh'] * 15.0 + $_POST['mm'] / 4.0 + $_POST['ss'] / 240.0;
}
if (isset($_POST['submit2'])) {
	$decDeg = $_POST['dd'] + $_POST['amam'] / 60.0 + $_POST['asas'] / 3600.0;
}
?>
</head>
<body>
<center>
<form method='post' name='hrminsDecDeg'>
<input type='text' name='hh' id='hh' size='2' />HH<input type='text' name='mm' id='mm' size='2' />MM<input type='text' name='ss' id='ss' size='2' />SS.SS
<br /><input type='submit' name='submit' value='Submit' />
</form>
<br /><br />
<form method='post' name='degminsiecDecDeg'>
<input type='text' name='dd' id='dd' size='2' />DD<input type='text' name='amam' id='amam' size='2' />MM<input type='text' name='asas' id='asas' size='2' />SS.SS
<br /><input type='submit2' name='submit2' value='Submit' />
</form>
<?php
if (isset($_POST['submit'])) {
	print "$decDeg";
}
if (isset($_POST['submit2'])) {
	print "$decDeg";
}
?>
</center>
</body>
</html>