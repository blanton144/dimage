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
