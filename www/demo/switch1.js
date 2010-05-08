function switch1(div) {
if (document.getElementById('image1')) {
var option=['image1','image2'];
for(var i=0; i<option.length; i++)
{ obj=document.getElementById(option[i]);
obj.style.display=(option[i]==div)? "block" : "none"; }
}
}
