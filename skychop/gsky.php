<html>
<head>
<title>
SDSS Sky Chop - Alpha Version
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
<script src="http://maps.google.com/maps?file=api&amp;v=2.x&amp;key=ABQIAAAApf7xUVmwSCZbEk-2IaOhQRQJG7NHkz3t4sN6fLBno0qVUQLbrhSt7A62doZlkAz4sWDWxhAyFYfQuQ"
  type="text/javascript"></script>
<script type="text/javascript">
var map;
function ra2lon(ra){
  var lon = 180 - ra;
  return lon;
}
function lon2ra(lon){
  var ra = 180 - lon;
  return ra;
}
function writeCenter(map){
  document.getElementById("ra").value = lon2ra(map.getCenter().lng());
  document.getElementById("dec").value = map.getCenter().lat();
}
function writeZoom(map){
  document.getElementById("zoom").value = map.getZoom();
}
function setSize(map){
	var bounds = map.getBounds();
	var southWest = bounds.getSouthWest();
	var northEast = bounds.getNorthEast();
	var lngSpan = southWest.lng() - northEast.lng();
	document.getElementById("sizex").value = Math.abs(lngSpan);
}
function CenterVP(){
  var ra = document.getElementById("ra").value;
  var dec = document.getElementById("dec").value;
  map.panTo(new GLatLng(dec, ra2lon(ra)));
}
function initialize() {
  if(GBrowserIsCompatible()){
    map = new GMap2(document.getElementById("sky_map"), {
      mapTypes : G_SKY_MAP_TYPES
      });
    var p = new GMercatorProjection(20);
    var mt = map.getMapTypes();
    mt[0].getProjection = function() {return p;}
    mt[0].getMaximumResolution = function() {return 14;}
    mt[0].getMinimumResolution = function() {return 3;}	
    map.setCenter(new GLatLng(document.getElementById("dec").value, ra2lon(document.getElementById("ra").value)), 10);
    map.addControl(new GLargeMapControl());
	map.setZoom(document.getElementById("zoom").value);
    GEvent.addListener(map, "moveend", function() {
      writeCenter(map);
	  setSize(map);
    });
	GEvent.addListener(map, "zoomend", function() {
      writeZoom(map);
    });
  }
}
</script>

<?php
	// Default settings for the Pinwheel Galaxy
	$RA = 210.80415;
	$dec = 54.34917;
	$sizeX = 0.6866455078;
	$zoom = 10;
	$fname = "";
	
	if (isset($_GET['submit'])) {
		$submitSuccess = True;
		// Get variables from form POST
		$RA = $_GET['ra'];
		$dec = $_GET['dec'];
		$sizeX = $_GET['sizex'];
		$sizeY = $sizeX;
		$g = $_GET['g'];
		$i = $_GET['i'];
		$r = $_GET['r'];
		$u = $_GET['u'];
		$z = $_GET['z'];
		$zoom = $_GET['zoom'];
		if ($_GET['tyn'] = 'on') { $tyn = 1; }
		else { $tyn = 0; }
		$all = $_GET['all'];
		$fname = str_replace(" ", "", stripslashes($_GET['fname'])); // Remove slashes and spaces from filename for security
			
		if ($fname == "" || $fname == "/") {
			$fname = rand(1000,9999999999);
		}
		
		// Test to see if the coordinates are in range
		$coord_test_out = exec("/usr/local/epd/bin/python test_the_coords.py $RA $dec 2>&1",$coord_test);
		// Figure out which bands are on and add the letters to an array
		if ($z == 'on') { $bands .= 'z'; $thmb = 'z'; }
		if ($u == 'on') { $bands .= 'u'; $thmb = 'u'; }
		if ($g == 'on') { $bands .= 'g'; $thmb = 'g'; }
		if ($i == 'on') { $bands .= 'i'; $thmb = 'i'; }
		if ($r == 'on') { $bands .= 'r'; $thmb = 'r'; }
		
		// Validate input
		if (strlen($bands) == 0) {
			print "<font class='errorText'><center>Please select a band!</center></font>";
			$submitSuccess = False;
		}
		if ($coord_test_out == 0 || $coord_test_out == '0') {
			print "<font class='errorText'><center>Coordinates out of range!</center></font>";
			$submitSuccess = False;
		}
		if (!(is_numeric($RA)) || !(is_numeric($dec)) || !(is_numeric($sizeX)) || !(is_numeric($sizeY))) {
			print "<font class='errorText'><center>Enter only numbers into coordinates and size!</center></font>";
			$submitSuccess = False;
		}
		if (strlen($fname) > 20) {
			print "<font class='errorText'><center>Custom filename must be < 20 characters.</center></font>";
			$submitSuccess = False;
		}
		if ($sizeX > 1.0) {
			print "<font class='errorText'><center>Size must be 0 < X <= 1.0</center></font>";
			$submitSuccess = False;
		}
		if ($submitSuccess) {
			$site = "process.php?ra=$RA&dec=$dec&xsize=$sizeX&ysize=$sizeY&bands=$bands&fname=$fname&thumb=$thmb&tyn=$tyn&proc=0";
			echo('<meta http-equiv="Refresh" content="1;url='.$site.'">');
		}
	}
?>
</head>
<body onLoad="initialize()" onUnload="GUnload()">
<table border='2' bordercolor="#000000" align='center'>
<tr>
	<td>
        <center>
        <div id="sky_map" style="height:700px;width:700px">
        </div>
        </center>   
    </td>
	<td>
      <form method='GET' name='imageChop'>
      	  <?php print "<input type='hidden' id='zoom' name='zoom' value='$zoom'/>"; ?>
          <table border='0' align="center">
             
              <tr>
                  <td valign='middle' align='center' colspan='2'><font class='title'>SDSS FITS <br />Image Generator</font><br /><br /></td>
              </tr>
          
              <tr>
                  <td align='right' valign='middle'><font class='theLabels'>RA:</font></td>
				  <?php
                          print "<td valign='middle'><input type='text' name='ra' id='ra' size='12' value='$RA' />";
                  ?>
                      <font class='notifyText'>degrees</font>
                  </td>
              </tr>
              
              <tr>
                  <td align='right' valign='middle'><font class='theLabels'>Dec:</font></td>
				  <?php
                          print "<td valign='middle'><input type='text' name='dec' id='dec' size='12' value='$dec' />";
                  ?>
                      <font class='notifyText'>degrees</font>
                  </td>
              </tr>
              
              <tr>
                  <td align='right' valign='middle'><font class='theLabels'>Size:</font></td>
				  <?php
                          print "<td valign='middle'><input type='text' name='sizex' id='sizex' size='12' value='$sizeX' />";
                  ?>
                      <font class='notifyText'>degrees</font>
                  </td>
              </tr>
              
              <tr>
              	  <td colspan="2" align="center">
                   	  <input type="button" id="center" value="Recenter Viewing Window" onClick="CenterVP()"/>
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
                  <td align="right"><font class='theLabels'>Output<br> File:</font></td>
                  <td>
                  <?php
                      print "<input type='text' name='fname' id='fname' size='10' value='$fname' />";
                  ?> 
                  .tar.gz <font class='notifyText'>(optional)</font></td>
              </tr>
              <tr>
                  <td colspan="2"><font class='theLabels'>Generate PNG thumbnail:</font>
                      <?php 
                          if ($_POST['tyn'] == 'on') {
                              print '<input type="checkbox" name="tyn" id="tyn" checked="yes" />'; 
                          }
                          else { 
                              print '<input type="checkbox" name="tyn" id="tyn" checked="no" />'; 
                          }
                      ?>
                  </td>
              </tr>
              <tr>
                  <td align='center' colspan='2' valign='bottom'><br />
                  <input type='submit' name='submit' value='Submit Query' />
              </tr>
          </table>
      </form>
      <br />
      <center><font class='notifyText'>Already have a session ID? <br /><a class='reDLink' href='revisit.php'>Click here to re-download your query results.</a></font></center>
      <br />
      <center><font class='notifyText'>Questions? Check the <a class='reDLink' href='FAQ.php'>FAQ.</a></font></center>
      <br />
      <center><font class='notifyText'>Report bugs to <a class='reDLink' href='mailto:apw235@nyu.edu'>Adrian Price-Whelan</a></font></center>
      <br />
</td>
</table>
</body>
</html>