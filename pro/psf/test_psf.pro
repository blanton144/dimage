pro test_psf, clobber= clobber, sub=sub, image=image

imbase= 'test_psf'
imfile= imbase+'.fits'

if(keyword_set(clobber) gt 0 AND $
   file_test(imfile) gt 0) then begin

   nx=1000L
   ny=1000L
   sky= 10.
   nstar= 500L
   seed=-10
   sigma1= 1.2
   sigma2= 2.4
   frac1= 0.6
   frac2= 1.-frac1
   gain= 10.
   
   noiseless= fltarr(nx, ny)
   xim= findgen(nx)#replicate(1., ny)
   yim= transpose(xim)
   
   x= randomu(seed, nstar)*float(nx)
   y= randomu(seed, nstar)*float(ny)
   
   minflux=500.
   maxflux=500000.
   flux= exp(alog(minflux)+randomu(seed, nstar)*(alog(maxflux)-alog(minflux)))
   
   for i=0L, nstar-1L do begin 
      help,i 
      tmp1=exp(-0.5*((x[i]-xim)^2+(y[i]-yim)^2)/sigma1^2)/ $
           (2.*!DPI*sigma1^2) 
      tmp2=exp(-0.5*((x[i]-xim)^2+(y[i]-yim)^2)/sigma2^2)/ $
           (2.*!DPI*sigma2^2) 
      noiseless+= (tmp1*frac1+tmp2*frac2)*flux[i] 
   endfor

   noiseless+= sky
   
   image= noiseless+ randomn(seed, nx,ny)*sqrt(noiseless*gain)- sky
   mwrfits, image, imfile, /create
endif

image= gz_mrdfits(imfile)

dfitpsf, imfile

sub= dpsfsub(imbase)

atv, sub

end
