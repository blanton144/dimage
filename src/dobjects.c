#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"
#include "export.h"

/*
 * dobjects.c
 *
 * Object detection
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static int *mask=NULL;

int dobjects(float *image, 
						 float *smooth,
             int nx, 
             int ny,
             float dpsf, 
             float plim, 
             int *objects)
{
  int i,j,ip,jp,ist,ind,jst,jnd;
  float limit,sigma;

  dsmooth(image, nx, ny, dpsf, smooth);

	dsigma(smooth, nx, ny, 2, &sigma);
  limit=sigma*plim;
  
  mask=(int *) malloc(nx*ny*sizeof(int));
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) 
      mask[i+j*nx]=0;
  for(j=0;j<ny;j++) {
    jst=j-(long) (3*dpsf);
    if(jst<0) jst=0;
    jnd=j+(long) (3*dpsf);
    if(jnd>ny-1) jnd=ny-1;
    for(i=0;i<nx;i++) {
      if(smooth[i+j*nx]>limit) {
        ist=i-(long) (3*dpsf);
        if(ist<0) ist=0;
        ind=i+(long) (3*dpsf);
        if(ind>nx-1) ind=nx-1;
        for(jp=jst;jp<=jnd;jp++) 
          for(ip=ist;ip<=ind;ip++) 
            mask[ip+jp*nx]= 1;
      }
    }
  }
      
  dfind(mask, nx, ny, objects);

  FREEVEC(mask);
    
	return(1);
} /* end dobjects */
