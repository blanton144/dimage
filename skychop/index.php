<html>
<head>
<title>
SDSS Sky Chop
</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="style.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
function checkUncheckAll(theElement) {
	var theForm = theElement.form, x = 0;
	for(x=0; x<theForm.length;x++){
		if(theForm[x].type == 'checkbox' && theForm[x].name != 'checkall') {
			theForm[x].checked = theElement.checked;
		}
	}
}
</script>

<?php
	function start_timer($filename, $old_line) {
		$file = fopen($filename, 'r');
		$line = fread($file, 1024);
		if ($line != $old_line) {
			$site = "http://sdss3.physics.nyu.edu/skychop/index.php?msg=$line";
		}
		else {
			$site = "http://sdss3.physics.nyu.edu/skychop/index.php?msg=$old_line&timer=1";
		}
		echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
		
	}
	
	ini_Set('display_errors',1); // turn on error reporting while developing
	$RA = 210.80415;
	$dec = 54.34917;
	$sizeX = 0.25;
	$sizeY = 0.25;
	
	if (isset($_POST['submit'])) {
		$submitSuccess = True;
		// Get variables from form POST
		$RA = $_POST['ra'];
		$dec = $_POST['dec'];
		$sizeX = $_POST['sizex'];
		$sizeY = $_POST['sizey'];
		$g = $_POST['g'];
		$i = $_POST['i'];
		$r = $_POST['r'];
		$u = $_POST['u'];
		$z = $_POST['z'];
		$all = $_POST['all'];
		$fname = stripslashes($_POST['fname']);
		$pid = rand(1000,9999999999);
		
		if ($fname == "") {
			$fname = $pid;
		}
		
		// Check to make sure the PID is not already the name of a directory
		/*
		while($entry = readdir($dir)) {
			if ($entry == $pid) {
				$pid = rand(1000,999999);
				break;
			}
			else { continue; }
		}
		closedir($dir);
		*/
		
		// Figure out which bands are on and add the letters to an array
		if ($g == 'on') { $bands .= 'g';}
		if ($i == 'on') { $bands .= 'i';}
		if ($r == 'on') { $bands .= 'r';}
		if ($u == 'on') { $bands .= 'u';}
		if ($z == 'on') { $bands .= 'z';}
		
		// Validate input
		if (strlen($bands) == 0) {
			print "<font class='errorText'><center>Please select a band!</center></font>";
			$submitSuccess = False;
		}
		if (!(is_numeric($RA)) || !(is_numeric($dec)) || !(is_numeric($sizeX)) || !(is_numeric($sizeY))) {
			print "<font class='errorText'><center>Please correct your input.</center></font>";
			$submitSuccess = False;
		}
		if (strlen($fname) > 20) {
			print "<font class='errorText'><center>Custom filename must be < 20 characters.</center></font>";
			$submitSuccess = False;
		}
		if ($sizeX > 1.0) {
			print "<font class='errorText'><center>Size must be 0 < X <= 1.0 and 0 < Y <= 1.0</center></font>";
			$submitSuccess = False;
		}
		if ($sizeY > 1.0) {
			print "<font class='errorText'><center>Size must be 0 < X <= 1.0 and 0 < Y <= 1.0</center></font>";
			$submitSuccess = False;
		}
		
		if ($submitSuccess) {
			$site = "process.php?ra=$RA&dec=$dec&xsize=$sizeX&ysize=$sizeY&bands=$bands&fname=$fname";
			echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
			//$test = exec("/usr/local/epd/bin/python $skychop/test_js_timer.py > $pid 2>&1 &");
			//start_timer($pid);
			
			/* Old, pre-js timer check
			if (empty($fname)) {
				$pysuccess = exec("/usr/local/epd/bin/python $skychop/find_image.py $RA $dec $sizeX $sizeY $bands $pid 2>&1",$output);
			}
			else {
				$pysuccess = exec("/usr/local/epd/bin/python $skychop/find_image.py $RA $dec $sizeX $sizeY $bands $fname 2>&1",$output);
			}
			if ($pysuccess == 0) {
				print "<font class='errorText'><center>Coordinates out of range.</center></font>";
				print_r($output);
			}
			if ($pysuccess != 1 && $pysuccess != 0) {
				print $pysuccess;
			}
			*/
		}
	}
?>
</head>
<body bgcolor="#eeeeee">

<form method='post' name='imageChop'>
	<table border='0' align='center'>
		<tr>
			<td valign='middle' align='center' colspan='2'><font class='theLabels'>Coordinates:</font></td>
		</tr>
	
		<tr>
			<td align='right' valign='middle'><font class='theLabels'>RA:</font></td>
			<?php
					print "<td valign='middle'><input type='text' name='ra' id='ra' size='10' value='$RA' />";
			?>
				<font class='notifyText'>degrees</font>
			</td>
		</tr>
		
		<tr>
			<td align='right' valign='middle'><font class='theLabels'>Dec:</font></td>
			<?php
					print "<td valign='middle'><input type='text' name='dec' id='dec' size='10' value='$dec' />";
			?>
				<font class='notifyText'>degrees</font>
			</td>
		</tr>
		
		<tr>
			<td align='right' valign='middle'><font class='theLabels'>Size:</font></td>
			<?php
				print "<td valign='middle'>x:<input type='text' name='sizex' id='sizex' size='5' value='$sizeX' /><font class='notifyText'>degrees</font><br />y:<input type='text' name='sizey' id='sizey' size='5' value='$sizeY' /><font class='notifyText'>degrees</font>"
			?>
			</td>
		</tr>
		
		<tr>
			<td align='right' valign='top'><font class='theLabels'>Band:</font></td>
			<td valign='middle' align='left'>
			<table>
				<tr>
					<td>all:</td>
					<td>
						<?php 
							if ($_POST['all'] == 'on') {
								print '<input type="checkbox" onClick="checkUncheckAll(this)" name="all" id="all" checked="yes" />'; 
							}
							else { 
								print '<input type="checkbox" onClick="checkUncheckAll(this)" name="all" id="all" />'; 
							}
						?>
					</td>
				</tr>
				<tr>
					<td>u:</td>
					<td>
						<?php 
							if ($_POST['u'] == 'on') {
								print '<input type="checkbox" name="u" id="u" checked="yes" />'; 
							}
							else { 
								print '<input type="checkbox" name="u" id="u" />'; 
							}
						?>
					</td>
				</tr>
				<tr>
					<td>g:</td>
					<td>
						<?php 
							if ($_POST['g'] == 'on') {
								print '<input type="checkbox" name="g" id="g" checked="yes" />'; 
							}
							else { 
								print '<input type="checkbox" name="g" id="g" />'; 
							}
						?>
					</td>
				</tr>
				<tr>
					<td>i:</td>
					<td>
						<?php 
							if ($_POST['i'] == 'on') {
								print '<input type="checkbox" name="i" id="i" checked="yes" />'; 
							}
							else { 
								print '<input type="checkbox" name="i" id="i" />'; 
							}
						?>
					</td>
				</tr>
				<tr>
					<td>r:</td>
					<td>
						<?php 
							if ($_POST['r'] == 'on') {
								print '<input type="checkbox" name="r" id="r" checked="yes" />'; 
							}
							else { 
								print '<input type="checkbox" name="r" id="r" />'; 
							}
						?>
					</td>
				</tr>
				<tr>
					<td>z:</td>
					<td>
						<?php 
							if ($_POST['z'] == 'on') {
								print '<input type="checkbox" name="z" id="z" checked="yes" />'; 
							}
							else { 
								print '<input type="checkbox" name="z" id="z" />'; 
							}
						?>
					</td>	
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td><font class='theLabels'>Output Filename:</font></td>
			<td><input type='text' name='fname' id='fname' size='10' />.tar.gz <font class='notifyText'>(optional)</font></td>
		</tr
		><tr>
			<td align='center' colspan='2' valign='bottom'><br />
			<input type='submit' name='submit' value='Submit' />
		</tr>
	</table>
</form>

<?php
	if (isset($_POST['submit'])) {
		if ($submitSuccess && ($pysuccess == 1)) {
			if (empty($fname)) {
				print "<center><a href='sdss-tmp/$pid.tar.gz'>Download Files</a></center>";
				print "<center><font class='notifyText'>Your session ID is: <b>$pid</b>. <br /> You can come back any time within 30 minutes to re-download the files.</font></center>";	
			}
			else {
				print "<center><a href='sdss-tmp/$fname.tar.gz'>Download Files</a></center>";
				print "<center><font class='notifyText'>Your session ID is: <b>$fname</b>. <br /> You can come back any time within 30 minutes to re-download the files.</font></center>";	

			}
		}
	}	
?>
<center><font class='notifyText'>Already have a session ID? <br /><a class='reDLink' href='revisit.php'>Click here to re-download your query results.</a></font></center>
</body>
</html>