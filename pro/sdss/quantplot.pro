;+
; NAME:
;   quantplot
; PURPOSE:
;   overplot quantiles as a function of the X variable
; CALLING SEQUENCE:
;   quantplot, x, y, npix=, quantiles=, weights=, minx=, maxx= [, $
;         inputs for djs_oplot]
; INPUTS:
;   x, y - [Nd] data values
; OPTIONAL INPUTS:
;   npix - number of pixels in X to use
;   minx, maxx - minimum and maximum values of X to look at
;   quantiles - [Nq] which quantiles to plot (default [0.25, 0.5, 0.75])
;   weights - [Nd] weights to use if quantiles are weighted
;   minnbin - minimum number of points in bin to use (default 10)
; OPTIONAL OUTPUTS:
;   outquantiles - [npix, Nq] quantile values for each pixel
;   xquantiles - [npix] position of each pixel
; REVISION HISTORY:
;   9-Mar-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro quantplot, in_x, in_y, weights=in_weights, $
               npix=npix, minx=minx, maxx=maxx, $
               quantiles=quantiles, minnbin=minnbin, $
               outquantiles=outquantiles, xquantiles=xquantiles, $
               _EXTRA=extra_for_oplot

ndata= n_elements(in_x)
if(ndata eq 0) then $
  message, 'Must give at least one element in X and Y'
if(ndata ne n_elements(in_y)) then $
  message, 'X and Y must be same size'

if not keyword_set(npix) then npix= ceil(0.3*sqrt(ndata)) > 10
if(npix lt 0) then $
  message, 'Number of pixels must be greater than zero'

if(keyword_set(quantiles) eq 0) then $
  quantiles= [0.25, 0.5, 0.75]
nquantiles=n_elements(quantiles)

if(n_elements(minnbin) eq 0) then $
  minnbin=10L

ibad=where(quantiles le 0. or quantiles ge 1., nbad)
if(nbad gt 0) then $
  message, 'Do not specify quantiles outside the (0-1) range'

if(keyword_set(in_weights) eq 0) then $
  in_weights= fltarr(ndata)+1.
if(ndata ne n_elements(in_weights)) then $
  message, 'weights must be same size as X and Y'

outquantiles= fltarr(npix,nquantiles)

if(keyword_set(minx) eq 0) then $
  minx=min(in_x)
if(keyword_set(maxx) eq 0) then $
  maxx=max(in_x)
ikeep= where(in_x ge minx and in_x le maxx, nkeep)
if(nkeep eq 0) then return
x=in_x[ikeep]
y=in_y[ikeep]
weights=in_weights[ikeep]
xgrid= long((x-minx)/(maxx-minx)*float(npix))
xquantiles= (findgen(npix)+0.5)/float(npix)*(maxx-minx)+minx

for i=0L,npix-1 do begin
    iin= where(xgrid EQ i,nin)
    if(nin ge minnbin) then begin
        outquantiles[i,*]= weighted_quantile(y[iin],weights[iin], $
                                             quant=quantiles)
    endif else begin
        outquantiles[i,*]= 0./0.
    endelse 
endfor

for i=0L, n_elements(quantiles)-1L do $
      djs_oplot, xquantiles, outquantiles[*, i], npix=100, $
                 _EXTRA=extra_for_oplot

end
