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
	//ini_Set('display_errors',1); // turn on error reporting while developing
	$RA = 210.80415;
	$dec = 54.34917;
	$sizeX = 0.25;
	$sizeY = 0.25;
	$fname = "";
	
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
		$fname = $_POST['fname'];
		$pid = rand(1000,9999999999);
		
		if ($fname == "" || $fname == "/") {
			$fname = $pid;
		}
		
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
			$site = "process.php?ra=$RA&dec=$dec&xsize=$sizeX&ysize=$sizeY&bands=$bands&fname=$fname&proc=0";
			echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
		}
	}
?>
</head>
<body>

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
			<td><input type='text' name='fname' id='fname' size='10' value=<?php "$fname";?> />.tar.gz <font class='notifyText'>(optional)</font></td>
		</tr
		><tr>
			<td align='center' colspan='2' valign='bottom'><br />
			<input type='submit' name='submit' value='Submit' />
		</tr>
	</table>
</form>
<center><font class='notifyText'>Already have a session ID? <br /><a class='reDLink' href='revisit.php'>Click here to re-download your query results.</a></font></center>
</body>
</html>