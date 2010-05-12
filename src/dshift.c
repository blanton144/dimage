#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dshift.c
 *
 * Shift a 2D image.
 * Inputs:
 * - image 
 * - nx, ny
 * - dx, dy 
 * - kernel (1d function; assumes separability!)
 * - nk (kernel size; best if ODD)
 *
 * Mike Blanton
 * 10/2009 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

void dshift(float *image,
						int nx,
						int ny,
						float dx,
						float dy,
						float (*kernel)(float),
						int nk)
{
	int idx, idy, i, j, k, ip, jp, start, end;
	float fdx, fdy, dk;
	float *xkernel, *ykernel;
	float *tmpimage, *newimage, *imagerow, *imagecol;

	xkernel=NULL;
	ykernel=NULL;
	tmpimage=NULL;
	newimage=NULL;
	imagerow=NULL;
	imagecol=NULL;

	/* divide shift into integer and non-integer parts */
	idx= (int) round(dx);
	idy= (int) round(dy);
	fdx= dx - (float) idx;
	fdy= dy - (float) idy;

	if(fdx!=0 || fdy!=0) {
	
		/* make the kernels */
		xkernel= (float *) malloc(nk*sizeof(float));
		ykernel= (float *) malloc(nk*sizeof(float));
		for(k=0;k<nk;k++) {
			dk = fdx + ((float) k - 0.5 * ((float)nk - 1.));
			xkernel[k]= (*kernel)(dk);
			dk = fdy + ((float) k - 0.5 * ((float)nk - 1.));
			ykernel[k]= (*kernel)(dk);
		}
		
		/* allocate new images */
		tmpimage= (float *) malloc(nx*ny*sizeof(float));
		newimage= (float *) malloc(nx*ny*sizeof(float));
		
		/* shift in X */
		for (j=0;j<ny;j++) {
			imagerow=image+j*nx;
			for (i=0;i<nx;i++) {
				start= i-nk/2; 
				start = MAX(start, 0);
				end= i+nk/2; 
				end = MIN(end, nx-1);
				tmpimage[i+j*nx]=0.0;
				for (ip=start;ip<= end;ip++)
					tmpimage[i+j*nx]+=imagerow[ip]*xkernel[ip-i+nk/2];
			} /* end for i */
		} /* end for j */
		
		/* shift in Y */
		for(i=0;i<nx;i++) {
			imagecol=tmpimage+i;
			for(j=0;j<ny;j++) {
				start= j-nk/2;
				start= MAX(start, 0);
				end= j+nk/2;
				end= MIN(end, ny-1);
				newimage[i+j*nx]=0.0;
				for (jp=start;jp<=end;jp++)
					newimage[i+j*nx]+=imagecol[jp*nx]*ykernel[jp-j+nk/2];
			} /* end for j */
		} /* end for i */
	} else {
		newimage= (float *) malloc(nx*ny*sizeof(float));
		for(j=0;j<ny;j++) 
			for(i=0;i<nx;i++) 
				newimage[i+j*nx]= image[i+j*nx];
	} /* end if..else */
	
	for(j=0;j<ny;j++) {
		jp= j-idy;
		jp= MIN(jp, ny-1);
		jp= MAX(jp, 0);
		for(i=0;i<nx;i++) {
			ip= i-idx;
			ip= MIN(ip, nx-1);
			ip= MAX(ip, 0);
			image[i+j*nx]= newimage[ip+jp*nx];
		}
	}
	
	FREEVEC(xkernel);
	FREEVEC(ykernel);
	FREEVEC(newimage);
	FREEVEC(tmpimage);
} /* end dshift */


