#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"
#include "export.h"

/*
 * dfluxes.c
 *
 *  Given templates and weights, determine pixel fluxes to assign to
 *  each child associated with each template.
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

#define FREEALL { FREEVEC(fr); FREEVEC(assigned); FREEVEC(stemplates);} 

static int *assigned=NULL;
static float *stemplates=NULL;
static float *fr=NULL;

int dfluxes(float *image, 
            float *templates, 
            float *weights,
						int nx, 
						int ny,
            float *xcen,
            float *ycen,
						int nchild, 
            float *children,
            float sigma)
{
  int i,j,k,kp;
  float r2, maxval, val, ss;

  /* 1. smooth templates*/
  stemplates=(float *) malloc(nx*ny*nchild*sizeof(float));
  for(k=0;k<nchild;k++) 
    dsmooth(&(templates[k*nx*ny]), nx, ny, 4., &(stemplates[k*nx*ny]));
  
  /* 2. then assign fluxes according to ratios (as long as pixels get
     enough total weight from templates) */
  assigned=(int *) malloc(nx*ny*sizeof(int));
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) 
      assigned[i+j*nx]=0;
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) {
      ss=0.;
      for(k=0;k<nchild;k++)
        ss+=weights[k]*templates[i+j*nx+nx*ny*k];
      if(ss>5.*sigma) { /* if total weight is large use full-res templates */
        for(k=0;k<nchild;k++)
          children[i+j*nx+nx*ny*k]= 
            image[i+j*nx]*weights[k]*templates[i+j*nx+nx*ny*k]/ss;
        assigned[i+nx*j]=1;
      } else { /* otherwise use smoothed templates */
        ss=0.;
        for(k=0;k<nchild;k++)
          ss+=weights[k]*stemplates[i+j*nx+nx*ny*k];
        if(ss>0.5*sigma) { /* but only if there is still enough weight */
          for(k=0;k<nchild;k++)
            children[i+j*nx+nx*ny*k]= 
              image[i+j*nx]*weights[k]*stemplates[i+j*nx+nx*ny*k]/ss;
          assigned[i+nx*j]=1;
        }
      }
    }

  /* 3. now assign flux in low weight pixels to most likely child */
  fr=(float *) malloc(nchild*sizeof(float)); 
  for(k=0;k<nchild;k++) {
    fr[k]=0.;
    for(j=0;j<ny;j++)
      for(i=0;i<nx;i++) {
        r2=((float) i - xcen[k])*((float) i - xcen[k])+
          ((float) j - ycen[k])*((float) j - ycen[k]);
        fr[k]+=children[i+j*nx+k*nx*ny]*r2;
      }
  }
  for(j=0;j<ny;j++)
    for(i=0;i<nx;i++) {
      if(!assigned[i+nx*j]) {
        maxval=-1.;
        kp=-1;
        for(k=0;k<nchild;k++) {
          r2=((float) i - xcen[k])*((float) i - xcen[k])+
            ((float) j - ycen[k])*((float) j - ycen[k]);
          val=fr[k]/r2;
          if(val>maxval) {
            maxval=val;
            kp=k;
          }
        }
        children[i+j*nx+kp*nx*ny]=image[i+j*nx];
      }
    }
    
  FREEALL;

	return(1);
} /* end deblend */

