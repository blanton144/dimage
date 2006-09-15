#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"
#include "export.h"

/*
 * dtemplates.c
 *
 *  Hardwired: level stepping to find saddles for trimming extra template peaks
 *
 * TODO:
 *   model templates and taper them (before trimming or after??)
 *   keep track of template boundaries, and don't bother with analysis outside
 *   remove low significance children
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

#define FREEALL { FREEVEC(peak); FREEVEC(sqnorms); FREEVEC(keep); }

static float *peak=NULL;
static float *sqnorms=NULL;
static int *keep=NULL;

int dtemplates(float *image, 
							 int nx, 
							 int ny,
							 int *ntemplates, 
							 int *xcen, 
							 int *ycen, 
							 float *templates, 
							 float sigma, 
							 float parallel)
{
  int i,j,k,ip,jp,di,dj,kp, tmpnt;
  float v1,v2,cross;

	printf("%d %d %d\n", nx, ny, *ntemplates);

  /* 2. construct templates */
  for(k=0;k<(*ntemplates);k++) {

    /* 2a. make a symmetric template */
    for(j=0;j<ny;j++) {
      dj=ycen[k]-j;
      jp=ycen[k]+dj;
      for(i=0;i<nx;i++) {
        di=xcen[k]-i;
        v1=image[i+j*nx];
        ip=xcen[k]+di;
        if(ip>=0 && jp>=0 && ip<nx && jp<ny) {
          v2=image[ip+jp*nx];
          templates[i+j*nx+nx*ny*k]=((v2<v1)?v2:v1); 
					if(v1<1.5*sigma && v2<1.5*sigma) 
						templates[i+j*nx+nx*ny*k]+=0.564189*sigma;
        } else {
          templates[i+j*nx+nx*ny*k]=0.;
        }
      }
    }
	}
	
  /* 3. scale templates */
	peak=(float *) malloc(sizeof(int)*(*ntemplates));
  for(k=0;k<(*ntemplates);k++) {
    peak[k]=0.;
    for(j=0;j<ny;j++) 
      for(i=0;i<nx;i++) 
        if(templates[i+j*nx+k*nx*ny]>peak[k])
          peak[k]=templates[i+j*nx+k*nx*ny];
    for(j=0;j<ny;j++) 
      for(i=0;i<nx;i++) 
        templates[i+j*nx+k*nx*ny]/=peak[k];
  }
	
  /* 4. check for very parallel templates and get rid */
  sqnorms=(float *) malloc(sizeof(float)*(*ntemplates));
  keep=(int *) malloc(sizeof(int)*(*ntemplates));
  for(k=0;k<(*ntemplates);k++) {
    sqnorms[k]=0;
    for(j=0;j<ny;j++) 
      for(i=0;i<nx;i++) 
        sqnorms[k]+=templates[i+j*nx+k*nx*ny]*templates[i+j*nx+k*nx*ny];
  }
  for(k=0;k<(*ntemplates);k++) 
    keep[k]=1;
  for(k=0;k<(*ntemplates);k++) 
    for(kp=k+1;kp<(*ntemplates);kp++) {
      if(k!=kp && keep[k]>0 && keep[kp]>0) {
        cross=0.;
        for(j=0;j<ny;j++) 
          for(i=0;i<nx;i++) 
            cross+=templates[i+j*nx+kp*nx*ny]*templates[i+j*nx+k*nx*ny];
        cross/=sqrt(sqnorms[k]*sqnorms[kp]);
        if(cross>parallel) {
          if(peak[k]>peak[kp]) 
            keep[kp]=0;
          else 
            keep[k]=0;
        }
      }
    }
  tmpnt=0;
  for(k=0;k<(*ntemplates);k++) {
    if(keep[k]) {
      xcen[tmpnt]=xcen[k];
      ycen[tmpnt]=ycen[k];
      for(j=0;j<ny;j++) 
        for(i=0;i<nx;i++) 
          templates[i+j*nx+tmpnt*nx*ny]=templates[i+j*nx+k*nx*ny];
      peak[tmpnt]=peak[k];
      tmpnt++;
    }
  }
  (*ntemplates)=tmpnt;

  FREEALL;

	return(1);
} /* end deblend */
