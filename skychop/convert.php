<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link href="style.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Convert</title>
<?php
if (isset($_POST['submit'])) {
	$decDeg = $_POST['hh'] * 15.0 + $_POST['mm'] / 4.0 + $_POST['ss'] / 240.0;
}
if (isset($_POST['submit2'])) {
	$decDeg = $_POST['dd'] + $_POST['amam'] / 60.0 + $_POST['asas'] / 3600.0;
}
if (isset($_POST['submit3'])) {
	$deg = int($_POST['dd']);
	$min = int(($_POST['dd'] - float(int($_POST['dd']))) * 60.0);
	$sec = ((($_POST['dd'] - float(int($_POST['dd']))) * 60.0) - int(($_POST['dd'] - float(int($_POST['dd']))) * 60.0)) * 60.0;
}
?>
</head>
<body>
<center><font class="regText">
<font class="theLabels">Convert Sexagesimal Time --> Decimal Degrees</font>
<form method='post' name='hrminsDecDeg'>
<input type='text' name='hh' id='hh' size='4' />hr
<input type='text' name='mm' id='mm' size='4' />'
<input type='text' name='ss' id='ss' size='4' />"
<br /><input type='submit' name='submit' value='Submit' />
</form>
<?php
if (isset($_POST['submit'])) {
	print "<font class='errorText'>$decDeg&deg;</font>";
}
?>
<br />

<font class="theLabels">Convert Sexagesimal Degrees --> Decimal Degrees</font>
<form method='post' name='degminsiecDecDeg'>
<input type='text' name='dd' id='dd' size='4' />&deg;
<input type='text' name='amam' id='amam' size='4' />'
<input type='text' name='asas' id='asas' size='4' />"
<br /><input type='submit' name='submit2' value='Submit' />
</form>
</font>
<?php
if (isset($_POST['submit2'])) {
	print "<font class='errorText'>$decDeg&deg;</font>";
}
?>

<font class="theLabels">Convert Decimal Degrees --> Sexagesimal Degrees</font>
<form method='post' name='decDegtoSexDeg'>
<input type='text' name='dd' id='dd' size='4' />&deg;
<br /><input type='submit' name='submit3' value='Submit' />
</form>
</font>
<?php
if (isset($_POST['submit3'])) {
	print "<font class='errorText'>$deg&deg;" + ":" + "$min" + ":" + "$sec</font>";
}
?>
</center>
</body>
</html>