im=pyfits.open('J120250.27+203811.9-33-atlas-0.fits.gz')
image=im[2].data
measure=pyfits.open('J120250.27+203811.9-33-measure.fits.gz')
ba90= measure[1].data['ba90']
phi90= measure[1].data['phi90']
xcen= measure[1].data['xcen']
ycen= measure[1].data['ycen']

petro= dimage.petro(image, xcen=xcen, ycen=ycen, ba=ba90, phi=phi90)

x= np.outer(np.ones(im[2].data.shape[0]),np.arange(im[2].data.shape[1]))
x= x-measure[1].data['xcen']
y= np.outer(np.arange(im[2].data.shape[0]),np.ones(im[2].data.shape[1]))
y= y-measure[1].data['ycen']

xp= (np.cos(PI/180.*phi90)*x - np.sin(PI/180.*phi90)*y)/ba90
yp= (np.sin(PI/180.*phi90)*x + np.cos(PI/180.*phi90)*y)
r2= xp**2+yp**2

isort= np.argsort(r2, axis=None)
pix=image.flat[isort]

ii= np.arange(len(pix))
radius= np.sqrt(r2.flat[isort])
sb= filters.savitzky_golay(pix, 201, 3)
flux= np.cumsum(pix)
meansb= flux/(ii+1.)

ratiop= sb/meansb

minradius=10.
ratiop0= 0.2+np.zeros(len(ratiop))
ibelow= np.nonzero((ratiop < ratiop0) * (radius > minradius))
petrorad= radius[np.min(ibelow)]

npetro= 2.
aprad= petrorad*npetro
interper= interpolate.interp1d(radius, flux)
petroflux=interper(aprad)

interper= interpolate.interp1d(flux, radius)
petror50=interper(petroflux*0.5)
petror90=interper(petroflux*0.9)

version='v1_0_0'
nsafile= os.getenv('ATLAS_DATA')+'/v1/nsa_v1_0_0.fits'
nsafp= pyfits.open(nsafile, memmap=True)
nsa= nsafp[1].data
nsa=nsa[np.nonzero((nsa['ra'] > 180.)*(nsa['ra'] < 195.)* 
                   (nsa['dec'] > 20.)*(nsa['dec'] < 22.))]
fp=pyfits.open('petro_v1_0_0.fits')
dd= fp[1].data


plt.plot(radius[0:2000], sb[0:2000]/meansb[0:2000])
plt.show()

plt.plot(radius[0:2000], sb[0:2000])
plt.plot(radius[0:2000], meansb[0:2000])
plt.plot(radius[0:2000], pix[0:2000], ',')
plt.show()

plt.imshow(r2, origin='upper')
plt.show()

galaxy={'subdir':'.', 
        'aid':0, 
        'pid':37, 
        'iauname':'J120118.12+201147.8'}
        
adir= os.path.join(galaxy['subdir'], 'atlases',
                   str(galaxy['pid']))
filebase= os.path.join(adir, galaxy['iauname']+'-'+
                       str(galaxy['pid']))
measfile= filebase+'-measure.fits.gz'
imbase= filebase+'-atlas-'+str(galaxy['aid'])
imfile= imbase+'.fits.gz'
print imfile
fp= pyfits.open(imfile)
image= fp[2].data
header= fp[2].header
imwcs= wcs.WCS(header)
fp.close()
fp= pyfits.open(measfile)
measure= fp[1].data
fp.close()
ba90= measure['ba90']
phi90= measure['phi90']
racen= measure['racen']
deccen= measure['deccen']
(xcen, ycen)= imwcs.wcs_world2pix(racen, deccen, 0)
(petroflux, ra,flux,msb,sb)= dimage.petro(image, xcen=xcen, ycen=ycen, 
                    ba=ba90, phi=phi90)


import astropy.io.fits as pyfits
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
from dimage.savitzky_golay import savitzky_golay

fp=pyfits.open('vA-1692.fits')
image=fp[0].data
ba=0.16
phi=45.05+90.

PI=3.14159265358979
nx=image.shape[0]
ny=image.shape[1]
xcen=float(nx)*0.5
ycen=float(ny)*0.5
    
# Set default return
rdict=dict()
rdict['flux']=-9999.
rdict['rad']=-9999.
rdict['r50']=-9999.
rdict['r90']=-9999.

# Create radius array defining how far pixels are from center, 
# accounting for axis ratio.
x= np.outer(np.ones(nx),np.arange(ny))
x= x-xcen
y= np.outer(np.arange(nx),np.ones(ny))
y= y-ycen
xp= (np.cos(PI/180.*phi)*x - np.sin(PI/180.*phi)*y)/ba
yp= (np.sin(PI/180.*phi)*x + np.cos(PI/180.*phi)*y)
r2= xp**2+yp**2

# Sort the pixels by that radius, storing the pixel flux, 
# the pixel index, the radius of the pixel, and the flux
# up to and including that pixel
isort= np.argsort(r2, axis=None)
pix=image.flat[isort]
radius= np.append(np.zeros(1),np.sqrt(r2.flat[isort]))
ipix= np.append(np.ones(1),np.arange(len(pix)))
flux= np.append(np.array(pix[0]),np.cumsum(pix))

# Choose outer radii of apertures, and calculate flux and area within,
# and also calculate an annular flux and area around each radius
rbins= np.arange(int(max(radius)-1.))+1.
rlo= rbins-0.5
rhi= rbins+0.5
interper= interpolate.interp1d(radius,flux) 
fbins= interper(rbins)
flobins= interper(rlo)
fhibins= interper(rhi)
interper= interpolate.interp1d(radius,ipix) 
abins= interper(rbins)
alobins= interper(rlo)
ahibins= interper(rhi)

# Find surface brightness, enclosed flux, mean surface brightness, 
# and Petrosian ratio
meansb= fbins/abins
sb= (fhibins-flobins)/(ahibins-alobins)
petroratio= sb/meansb

ratiop0= petroratio0+np.zeros(len(petroratio))
ibelow= np.nonzero((petroratio < ratiop0) * (rbins >= minpetrorad))
ilowest= np.min(ibelow)
icheck= np.array((ilowest, ilowest-1))
interper=interpolate.interp1d(petroratio[icheck], rbins[icheck])
petrorad= interper(petroratio0)

plt.clf()
plt.plot(radius, pix)
plt.plot(radius, sb)
plt.plot(radius, meansb)
plt.show()

plt.clf()
plt.plot(radius, petroratio)
plt.show()


import matplotlib.pyplot as plt
import astropy.io.fits as pyfits
import numpy as np
import scipy.ndimage.filters as filters
fp= pyfits.open('J082845.60+503645.6-pimage.fits.gz')
pimage= fp[0].data
fp.close()
fp= pyfits.open('J082845.60+503645.6-r.fits.gz')
rimage= fp[0].data
bimage= np.float32(pimage > 0.)
cimage= filters.uniform_filter(bimage, 41)
dimage= np.float32(cimage > 0.)
izero= np.nonzero(dimage.flat == 0.)
print np.median(rimage.flat[izero])

import numpy as np
import astropy.io.fits as pyfits
fp= pyfits.open('nsa_v1_0_0.fits')
print np.nonzero(fp[1].data['nsaid'] == 592028)
