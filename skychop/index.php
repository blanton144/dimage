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

function getXMLHTTP() { 
		var xmlhttp=false;	
		try{
			xmlhttp=new XMLHttpRequest();
		}
		catch(e)	{		
			try{			
				xmlhttp= new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(e){
				try{
				xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
				}
				catch(e1){
					xmlhttp=false;
				}
			}
		}
		 	
		return xmlhttp;
	}
	
function getTBVal(strURL,raOrDec) {
  var req = getXMLHTTP();
  if (req)
  {
        //function to be called when state is changed
        req.onreadystatechange = function()
        {
          //when state is completed i.e 4
          if (req.readyState == 4)
          {
                // only if http status is "OK"
                if (req.status == 200)
                {
                        document.getElementById(raOrDec).value=req.responseText;
                }
                else
                {
                        alert("There was a problem while using XMLHTTP:\n" + req.statusText);
                }
          }
        }
        req.open("GET", strURL, true);
        req.send(null);
  }
}
</script>

<?php
	ini_Set('display_errors',1); // turn on error reporting while developing
	$RA = "210.80415";
	$dec = "54.34917";
	
	if (isset($_POST['submit'])) {
		$submitSuccess = True;
		// Get variables from form POST
		$RA = $_POST['ra'];
		$dec = $_POST['dec'];
		$size = $_POST['size'];
		$g = $_POST['g'];
		$i = $_POST['i'];
		$r = $_POST['r'];
		$u = $_POST['u'];
		$z = $_POST['z'];
		$all = $_POST['all'];
		$fname = stripslashes($_POST['fname']);
		
		// Other variable declarations
		$skychop = "/var/www/html/sdss3/skychop";
		$pid = rand(1000,99999);
		$dir = opendir("$skychop/sdss-tmp");
		
		// Check to make sure the PID is not already the name of a directory
		while($entry = readdir($dir)) {
			if ($entry == $pid) {
				$pid = rand(1000,99999);
				break;
			}
			else { continue; }
		}
		closedir($dir);
		
		// Figure out which bands are on and add the letters to an array
		if ($g == 'on') { $bands[] = 'g';}
		if ($i == 'on') { $bands[] = 'i';}
		if ($r == 'on') { $bands[] = 'r';}
		if ($u == 'on') { $bands[] = 'u';}
		if ($z == 'on') { $bands[] = 'z';}
		
		// Validate input
		if (count($bands) == 0) {
			print "<font class='errorText'><center>Please select a band!</center></font>";
			$submitSuccess = False;
		}
		if (!(is_numeric($RA)) || !(is_numeric($dec)) || !(is_numeric($size))) {
			print "<font class='errorText'><center>Please correct your input.</center></font>";
			$submitSuccess = False;
		}
		if (strlen($fname) > 20) {
			print "<font class='errorText'><center>Custom filename must be < 20 characters.</center></font>";
			$submitSuccess = False;
		}
		if ($submitSuccess) {
			$fileDir_and_fileName = exec("/usr/local/epd/bin/python $skychop/find_image.py $RA $dec");
			if (empty($fileDir_and_fileName)) {
				print "<font class='errorText'><center>Coordinates not within range.</center></font>";
			}
			else {
			  list($fileDir, $fileName) = split('[ ]', $fileDir_and_fileName);
			  
			  foreach($bands as $let) {
				  $unzip = exec("gunzip -c $fileDir$fileName/$fileName-$let.fits.gz > $skychop/sdss-tmp/$fileName-$let.fits");
				  $clip = exec("/usr/local/epd/bin/python $skychop/clipfits.py $skychop/sdss-tmp $fileName-$let.fits $RA $dec $size $fileName-$let-$size.fits 2>&1");
				  $rmOld = unlink("/var/www/html/sdss3/skychop/sdss-tmp/$fileName-$let.fits");
			  }
			  if (empty($fname) == False) {
				  $tar = exec("tar -cvvf sdss-tmp/$fname.tar sdss-tmp/*.fits");
				  $gz = exec("gzip sdss-tmp/$fname.tar");
				  $chmod_tar = chmod("sdss-tmp/$fname.tar.gz", 0777);
			  }
			  else {
				  $tar = exec("tar -cvvf sdss-tmp/$pid.tar sdss-tmp/*.fits");
				  $gz = exec("gzip sdss-tmp/$pid.tar");
				  $chmod_tar = chmod("sdss-tmp/$pid.tar.gz", 0777);
			  }
			  foreach($bands as $let) {
				  $rmOld = unlink("/var/www/html/sdss3/skychop/sdss-tmp/$fileName-$let-$size.fits");
			  }
			}
			
			/*
			print "$unzip<br />";
			print "$clip<br />";
			print "$rmOld<br />";
			print "$tar<br />";
			print "$gz<br />";
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
				if ($submitSuccess) {
					print "<td valign='middle'><input type='text' name='ra' id='ra' size='10' value='$RA' />";
				}
				else {
					print "<td valign='middle'><input type='text' name='ra' id='ra' size='10' value='$RA' />";
				}
			?>
				<font class='notifyText'>degrees</font>
			</td>
		</tr>
		
		<tr>
			<td align='right' valign='middle'><font class='theLabels'>Dec:</font></td>
			<?php
				if ($submitSuccess) {
					print "<td valign='middle'><input type='text' name='dec' id='dec' size='10' value='$dec' />";
				}
				else {
					print "<td valign='middle'><input type='text' name='dec' id='dec' size='10' value='$dec' />";
				}
			?>
				<font class='notifyText'>degrees</font>
			</td>
		</tr>
		
		<tr>
			<td align='right' valign='middle'><font class='theLabels'>Size:</font></td>
			<td valign='middle'><input type='text' name='size' id='size' size='10' value='0.5' />
			<font class='notifyText'>max. value = 1.0</font>
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
		if ($submitSuccess && !empty($fileDir_and_fileName)) {) {
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