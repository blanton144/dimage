#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"

/*
 * dcentral.c
 *
 * Find peaks in an image, for the purposes of deblending children.
 *
 * Hardwired: median box size choice
 *            search near peak size
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float *smooth=NULL;
static int *sxcen=NULL;
static int *sycen=NULL;

int dcentral(float *image, 
             int nx, 
             int ny,
             int npeaks, 
             float *xcen, 
             float *ycen, 
             int *central, 
             float sigma,   /* sky sigma */
             float dlim,    /* limiting distance */
             float saddle,
             int maxnpeaks)
{
  int box, nspeaks, k, ist, ind, jst, jnd, kmin, found;
  float dist2, mindist2;
  
  /* 1. median smooth image */
  smooth=(float *) malloc(sizeof(float)*nx*ny);
  box=2*(nx/16)+1;
  if(box<5) box=5;
  if(box>31) box=31;
  dmsmooth(image, nx, ny, box, smooth);

  /* 2. find brightest peak in smoothed image */
  sxcen=(int *) malloc(sizeof(int)*1);
  sycen=(int *) malloc(sizeof(int)*1);
  dpeaks(image, nx, ny, &nspeaks, sxcen, sycen, sigma, dlim, saddle, 1, 1, 
         1, 1.*sigma);

  /* 3. find brightest original peak near median peak */
  ist=(long) sxcen[0] - box/3;
  jst=(long) sycen[0] - box/3;
  ind=(long) sxcen[0] + box/3;
  jnd=(long) sycen[0] + box/3;
  found=0;
  for(k=0;k<npeaks && !found;k++) 
    if((long) xcen[k] >= ist &&
       (long) xcen[k] <= ind &&
       (long) ycen[k] >= jst &&
       (long) ycen[k] <= jnd) found=1;
  k--;

  /* 4. if there is no peak among the originals find the closest */
  if(found==0) {
    mindist2=nx*ny*nx*ny;
    kmin=-1;
    for(k=0;k<npeaks;k++) {
      dist2=(xcen[k]-sxcen[0])*(xcen[k]-sxcen[0])+
        (ycen[k]-sycen[0])*(ycen[k]-sycen[0]);
      if(dist2<mindist2) {
        mindist2=dist2;
        kmin=k;
      }
    }
    k=kmin;
  }
  
  *central=k;
  
  FREEVEC(smooth);
  FREEVEC(sxcen);
  FREEVEC(sycen);

	return(1);
} /* end dpeaks */
