#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"
#include "export.h"

/*
 * dweights.c
 *
 *  Given templates, and an image, find best weights in fit of
 *  templates to image.
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

#define FREEALL {FREEVEC(invcovar);FREEVEC(bb);FREEVEC(pp);}

static float *invcovar=NULL;
static float *bb=NULL;
static float *pp=NULL;


int dweights(float *image, 
             float *invvar,
             int nx, 
             int ny,
             int ntemplates, 
             float *templates, 
             int nonneg, 
             float *weights) 
{
  int i,j,k,kp,maxiter,niter;
  float offset,tol,chi2;

  maxiter=50000;
  tol=1.e-6;

  /* 1. create A matrix */
  invcovar=(float *) malloc(ntemplates*ntemplates*sizeof(float));
  bb=(float *) malloc(ntemplates*sizeof(float));
	pp=(float *) malloc(ntemplates*sizeof(float));
  for(k=0;k<ntemplates;k++)
    for(kp=0;kp<ntemplates;kp++) {
      invcovar[k+kp*ntemplates]=0.;
      for(j=0;j<ny;j++) 
        for(i=0;i<nx;i++) 
          invcovar[k+kp*ntemplates]+=templates[i+j*nx+k*nx*ny]*
            templates[i+j*nx+kp*nx*ny] *invvar[i+j*nx];
    }

  /* 2. create b vector for RHS */
  for(k=0;k<ntemplates;k++) {
    bb[k]=0.;
    for(j=0;j<ny;j++) 
      for(i=0;i<nx;i++) 
        bb[k]+=templates[i+j*nx+k*nx*ny]*image[i+j*nx] *invvar[i+j*nx];
  }
  offset=0.;
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) 
      offset+=image[i+j*nx]*image[i+j*nx]*invvar[i+j*nx];
  offset*=0.5;

  /* 3. solve linearly */
  dcholdc(invcovar,ntemplates,pp);
  dcholsl(invcovar,ntemplates,pp,bb,weights);

  /* 4. if nonneg, use that as starting point */
  if(nonneg) {
    for(k=0;k<ntemplates;k++)
      bb[k]=-bb[k];
    for(k=0;k<ntemplates;k++)
      weights[k]=fabs(weights[k]);
    dnonneg(weights, invcovar, bb, offset, ntemplates, tol, maxiter, &niter, 
            &chi2, 0);
  }
  
  FREEALL;

	return(1);
} /* end deblend */

