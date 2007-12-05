xx=findgen(3)#replicate(1.,3)
yy=transpose(xx)

sigma=1.2
xcen=0.6
ycen=1.6
a=exp(-0.5*((xx-xcen)^2+(yy-ycen)^2)/(sigma)^2)

dcen3x3, a, x, y
print,x,y
