<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>SkyChop FAQ</title>
<link href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
<table width="700" border="0" align="center">
<tr>
	<td>
		<div class="faqHead">How do I automatically make requests without using the web form?</div>
    </td>
</tr>
<tr>
	<td><div class="faqText">If you have many queries you want to run, the best thing to do is to write a script that calls process.php with the following GET 
variables: ra, dec, xsize, ysize, bands, fname, thumb, tyn, and proc.<br /><br /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>ra:</i> Right ascension in units Degrees<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>dec:</i> Declination in units Degrees<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>xsize:</i> Image must be square, so xsize must equal ysize, which are the dimensions in units degrees of the image<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>ysize:</i> Image must be square, so ysize must equal xsize, which are the dimensions in units degrees of the image<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>bands:</i> The bands you want returned, examples would be ‘ugr’ or ‘riz’ or simply ‘r’<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>fname:</i> The filename you want for the tarball of the returned FITS files<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>thumb:</i> Which band to generate the thumbnail from, set it to any band that you are requesting and set tyn=0<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>tyn:</i> For multiple queries, set tyn=0<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>proc:</i> This must be set to 1 for the script to run<br /><br />
A few example requests:<br /> 
http://sdss.physics.nyu.edu/sdss3/skychop/process.php?ra=210.51&dec=54.35&xsize=0.25&ysize=0.25&bands=ugi&fname=test_query&thumb=i&tyn=0&proc=1<br />
http://sdss.physics.nyu.edu/sdss3/skychop/process.php?ra=185.32&dec=21.66&xsize=1.0&ysize=1.0&bands=ugriz&fname=test_query&thumb=r&tyn=0&proc=1<br />
</div>
<br /><br />
<center><font class='notifyText'>Report bugs and ask questions to <a class='reDLink' href='mailto:apw235@nyu.edu'>Adrian Price-Whelan</a></font></center>
</td>
</tr>
</table>
</body>
</html>