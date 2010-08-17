;+
; NAME:
;   velmod_distance
; PURPOSE:
;   given a redshift, ra, and dec, return probability distribution of distances
; CALLING SEQUENCE:
;   ldist= velmod_distance(z, ra, dec [, beta= ])
; INPUTS:
;   z - [N] redshift
;   ra - [N] right ascension (J2000 deg)
;   dec - [N] declination (J2000 deg)
; OPTIONAL INPUTS:
;   beta - beta value (omega0^0.6/b) [default 0.5]
;   sigv - velocity dispersion in km/s [default 150]
; OUTPUTS:
;   ldist - structure with:
;                DISTANCE - most likely, in km/s, from MW center
;                DISTARR[] - distance array
;                LIKEARR[] - likelihood array
; COMMENTS:
;   Velocity field used is based on the results of VELMOD (a la
;   Willick, Strauss, Dekel & Kolatt 1997, ApJ 486, 629).
;   For a smooth transition to hi-z, this code tapers the velocity
;   field to zero between 5000 and 6400 km/s
; REVISION HISTORY:
;   7-Apr-2004  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function velmod_distance, z, ra, dec, beta=beta, sigv=sigv

common com_velmod_distance, dengrid, vxgrid, vygrid, vzgrid, cell, $
  nx, ny, nz, mwv

if(NOT keyword_set(beta)) then beta=0.5
if(NOT keyword_set(sigv)) then sigv=150.
if(NOT keyword_set(rbin)) then rbin=10.
if(NOT keyword_set(nbin)) then nbin=640L
if(NOT keyword_set(taper)) then taper=50.

; get local group relative motion
cspeed=2.99792e+5
d2r=!DPI/180.
cz=z*cspeed
cz_lg=vhelio_to_vlg(cz,ra,dec)

; get supergalactic coords
glactc, ra, dec, 2000, sgl, sgb, 1, /deg, /super

if(n_elements(dengrid) eq 0) then begin
;   load density and velocity grids
    dengrid=mrdfits(getenv('VAGC_DIR')+'/data/velfield/iter10.dengrid.fits')
    nx=(size(dengrid,/dim))[0]
    ny=(size(dengrid,/dim))[1]
    nz=(size(dengrid,/dim))[2]
    cell=100.
    velgrid=mrdfits(getenv('VAGC_DIR')+'/data/velfield/iter10.velgrid.fits')
    vxgrid=reform(velgrid[0,*,*,*],nx,ny,nz)
    vygrid=reform(velgrid[1,*,*,*],nx,ny,nz)
    vzgrid=reform(velgrid[2,*,*,*],nx,ny,nz)
    mwv=fltarr(3)
    mwv[0]=interpolate(vxgrid, float(nx)/2., float(ny)/2., float(nz)/2.)
    mwv[1]=interpolate(vygrid, float(nx)/2., float(ny)/2., float(nz)/2.)
    mwv[2]=interpolate(vzgrid, float(nx)/2., float(ny)/2., float(nz)/2.)
    vxgrid=vxgrid-mwv[0]
    vygrid=vygrid-mwv[1]
    vzgrid=vzgrid-mwv[2]
    xd=fltarr(nx,ny,nz)
    yd=fltarr(nx,ny,nz)
    zd=fltarr(nx,ny,nz)
    for i=0L, nx-1L do $
      for j=0L, ny-1L do $
      zd[i,j,*]=findgen(nz)-float(nz)/2.
    for i=0L, nx-1L do $
      for k=0L, nz-1L do $
      yd[i,*,k]=findgen(ny)-float(ny)/2.
    for j=0L, ny-1L do $
      for k=0L, nz-1L do $
      xd[*,j,k]=findgen(nx)-float(nx)/2.
    dist=sqrt(xd^2+yd^2+zd^2)
    iout=where(dist gt 64., nout) 
    if(nout gt 0) then begin
        vxgrid[iout]=0.
        vygrid[iout]=0.
        vzgrid[iout]=0.
    endif
    itaper=where(dist gt taper and dist le 64., ntaper) 
    if(ntaper gt 0) then begin
        tdot=-1.5*(dist[itaper]-0.5*(64.+taper))/(0.5*(64.-taper))
        factor=0.5*(1.+(exp(tdot)-exp(-tdot))/(exp(tdot)+exp(-tdot)))
        vxgrid[itaper]=vxgrid[itaper]*factor
        vygrid[itaper]=vygrid[itaper]*factor
        vzgrid[itaper]=vzgrid[itaper]*factor
    endif
endif

ldist1={distance:0., distance_err:0., maxlike:0., $
        distarr:(findgen(nbin)+0.5)*rbin, likearr:fltarr(nbin)} 
ldist=replicate(ldist1,n_elements(z))
currsig=sigv
for i=0L, n_elements(z)-1L do begin
    if((i mod 100) eq 0) then splog,i 
;   step outward from center
    currcz=fltarr(nbin)
    gaussexp=fltarr(nbin)
    for j=0L, nbin-1L do begin
;       at each step, compure likelihood of given velocity    
        currdir=fltarr(3)
        icurr=fltarr(3)
        currv=fltarr(3)
        currdir[0]=cos(sgl[i]*d2r)*cos(sgb[i]*d2r)
        currdir[1]=sin(sgl[i]*d2r)*cos(sgb[i]*d2r)
        currdir[2]=sin(sgb[i]*d2r)
        icurr[0]=ldist[i].distarr[j]*currdir[0]/cell+float(nx)/2.
        icurr[1]=ldist[i].distarr[j]*currdir[1]/cell+float(ny)/2.
        icurr[2]=ldist[i].distarr[j]*currdir[2]/cell+float(nz)/2.
        currv[0]=interpolate(vxgrid, icurr[0], icurr[1], icurr[2])
        currv[1]=interpolate(vygrid, icurr[0], icurr[1], icurr[2])
        currv[2]=interpolate(vzgrid, icurr[0], icurr[1], icurr[2])
        currv=currv*beta
        currcz[j]=float(total(currv*currdir,/double))+ldist[i].distarr[j]
        currd=interpolate(dengrid, icurr[0], icurr[1], icurr[2])
        ;; factor to make it well behaved
        gaussexp[j]=-0.5*(cz_lg[i]-currcz[j])^2/currsig^2
        ldist[i].likearr[j]= ldist[i].distarr[j]^2/sqrt(2.*!DPI*currsig^2)
    endfor
    factor=max(gaussexp)
    gaussexp=gaussexp-factor
    ldist[i].likearr= ldist[i].likearr*exp(gaussexp)
;   find peak 
    mx=max(ldist[i].likearr, jmx)
    if(jmx gt 0 and jmx lt nbin-1L) then begin
        d0=ldist[i].distarr[jmx-1L]
        l0=(ldist[i].likearr[jmx-1L])
        l1=(ldist[i].likearr[jmx])
        l2=(ldist[i].likearr[jmx+1L])
        ldist[i].distance=d0+0.5*rbin-(l1-l0)*rbin/(l2-2*l1+l0)
    endif else begin
        ldist[i].distance=ldist[i].distarr[jmx]
    endelse
;   get value at peak
    icurr[0]=ldist[i].distance*currdir[0]/cell+float(nx)/2.
    icurr[1]=ldist[i].distance*currdir[1]/cell+float(ny)/2.
    icurr[2]=ldist[i].distance*currdir[2]/cell+float(nz)/2.
    currv[0]=interpolate(vxgrid, icurr[0], icurr[1], icurr[2])
    currv[1]=interpolate(vygrid, icurr[0], icurr[1], icurr[2])
    currv[2]=interpolate(vzgrid, icurr[0], icurr[1], icurr[2])
    currv=currv*beta
    currcz=float(total(currv*currdir,/double))+ldist[i].distance
    currd=interpolate(dengrid, icurr[0], icurr[1], icurr[2])
    gaussexp=-0.5*(cz_lg[i]-currcz)^2/currsig^2
    ldist[i].maxlike= ldist[i].distance^2/sqrt(2.*!DPI*currsig^2)* $
      exp(gaussexp-factor)
    iless=where(ldist[i].distarr le ldist[i].distance and $
                ldist[i].likearr gt ldist[i].maxlike*exp(-2.0), nless)
    itwosigless=min(iless)
    imore=where(ldist[i].distarr ge ldist[i].distance and $
                ldist[i].likearr gt ldist[i].maxlike*exp(-2.0), nmore)
    itwosigmore=max(imore)
    if(itwosigmore eq n_elements(ldist[i].likearr)-1L) then begin
        ldist[i].distance_err= $
          (ldist[i].distance-ldist[i].distarr[itwosigless])/2.
    endif else if(itwosigless eq 0) then begin
        ldist[i].distance_err= $
          (ldist[i].distarr[itwosigmore]-ldist[i].distance)/2.
    endif else begin
        ldist[i].distance_err= $
          (ldist[i].distarr[itwosigmore]-ldist[i].distarr[itwosigless])/4.
    endelse
endfor

return, ldist

end
