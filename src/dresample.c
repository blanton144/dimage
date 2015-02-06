#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dresample.c
 *
 * Resample an image. 
 *
 * Mike Blanton
 * 10/2009 */

#define PI 3.14159265358979

static int *indx=NULL;
static int *isort=NULL;

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int dresample_pixel_sort(const void *first, const void *second)
{
  float v1,v2;
  v1=isort[*((int *) first)];
  v2=isort[*((int *) second)];
  if(v1>v2) return(-1);
  if(v1<v2) return(1);
  return(0);
}

void dresample(float *image,
							 int nx,
							 int ny,
							 float *xx, 
							 float *yy, 
							 int nn,
							 float *samples, 
							 float (*kernel)(float),
							 int nk)
{
	float xcurr, ycurr, dx, dy, xkernel, ykernel;
	int k, i, j, xst, xnd, yst, ynd;

	isort=NULL;
	indx=NULL;

	/* sort desired samples by memory location */ 
	isort= (int *) malloc(nn*sizeof(int));
	for(k=0;k<nn;k++)
		isort[k]= ((int) yy[k])+ny*((int) xx[k]);
  indx=(int *) malloc(sizeof(int)*nn);
  for(k=0;k<nn;k++)
		indx[k]=k;
	qsort((void *) indx, nn, sizeof(int), dresample_pixel_sort);

	/* for each sample */
	for(k=0;k<nn;k++) {
		xcurr= xx[indx[k]];
		ycurr= yy[indx[k]];

		/* get x range */
		xst= (int) ceil(xcurr-(float) (nk/2));
		if(xst<0) xst=0;
		if(xst>(nx-1)) xst=(nx-1);
		xnd= (int) floor(xcurr+(float) (nk/2));
		if(xnd<0) xst=0;
		if(xnd>(nx-1)) xnd=(nx-1);

		/* get y range */
		yst= (int) ceil(ycurr-(float) (nk/2));
		if(yst<0) yst=0;
		if(yst>(ny-1)) yst=(ny-1);
		ynd= (int) floor(ycurr+(float) (nk/2));
		if(ynd<0) yst=0;
		if(ynd>(ny-1)) ynd=(ny-1);

		/* loop over image */
		samples[indx[k]]=0.;
		for(j=yst;j<=ynd;j++) {
			dy= ycurr- (float) j;
			ykernel= (*kernel)(dy);
			for(i=xst;i<=xnd;i++) {
				dx= xcurr- (float) i;
				xkernel= (*kernel)(dx);
				samples[indx[k]]+= image[j+ny*i]*xkernel*ykernel;
			} /* end for j */
		} /* end for i */
	} /* end for k */

	FREEVEC(indx);
	FREEVEC(isort);
} /* end dresample */

