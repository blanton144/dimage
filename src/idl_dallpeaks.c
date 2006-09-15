#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dallpeaks(float *image, 
							int nx, 
							int ny,
							int *objects, 
							float *xcen, 
							float *ycen, 
							int *npeaks, 
							float sigma, 
							float dlim, 
							float saddle, 
							int maxper,
							int maxnpeaks,
							float minpeak);

/********************************************************************/
IDL_LONG idl_dallpeaks (int      argc,
												void *   argv[])
{
	int nx, ny, *objects, *npeaks, maxper, maxnpeaks;
	float *image, *xcen, *ycen, sigma, dlim, saddle, minpeak;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
  nx=*((int *)argv[i]); i++;
  ny=*((int *)argv[i]); i++;
  objects=((int *)argv[i]); i++;
  xcen=((float *)argv[i]); i++;
  ycen=((float *)argv[i]); i++;
  npeaks=((int *)argv[i]); i++;
  sigma=*((float *)argv[i]); i++;
  dlim=*((float *)argv[i]); i++;
  saddle=*((float *)argv[i]); i++;
  maxper=*((int *)argv[i]); i++;
  maxnpeaks=*((int *)argv[i]); i++;
  minpeak=*((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dallpeaks(image, nx, ny, objects, (float *) xcen, 
															(float *) ycen, (int *) npeaks, sigma, dlim, 
															saddle, maxper, maxnpeaks, minpeak);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

