<?php
if (isset($_POST['submit'])) {
	session_start(); 
}
?>
<html>
<head>
<title>
SDSS Sky Chop - Enter your session ID
</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="style.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#eeeeee">

<form method='post' name='getPack'>
<?php
	
	if (isset($_POST['submit'])) {
		// Test to make sure we have a number here;
		$sid = $_POST['sid'];
	
		if (!(is_numeric($sid))) {
				$sid = stripslashes($sid);
		}

		// Check to see if it is a valid SID
		$flag = '0';
		$dir = opendir("sdss-tmp");
		
		while($entry = readdir($dir)) {
			if ($entry == "$sid.tar.gz") {
				$flag = '1';
				break;
			}
			else {
				continue;
			}
		}
		closedir($dir);

		if ($flag == '1') {
			print "<center><font class='theLabels'>Session ID:</font><input type='text' name='sid' id='sid' size='10' value='$sid' />";
			print "<br /><input type='submit' name='submit' value='Submit' /></center>";
			print "<br /><center><a href='sdss-tmp/$sid.tar.gz'>Download Files</a></center>";
		}
		else {
			print "<center><font class='theLabels'>Session ID:</font><input type='text' name='sid' id='sid' size='10' value='$sid' />";
			print "<br /><input type='submit' name='submit' value='Submit' /></center>";
			print "<center><font class='errorText'>Your session has expired or session ID is invalid!</font></center>";
		}
	}
	
	else {
		print "<center><font class='theLabels'>Session ID:</font><input type='text' name='sid' id='sid' size='10' />";
		print "<br /><input type='submit' name='submit' value='Submit' /></center>";
	}
?>
</form>
<center><a href='index.php'>Return to Index</a></center>
</body>
</html>