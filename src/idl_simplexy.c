#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int simplexy(float *image, 
						 int nx, 
						 int ny,
						 float dpsf,
						 float plim,
						 float dlim, 
						 float saddle,
						 int maxper, 
						 int maxnpeaks,
						 float *sigma, 
						 float *x, 
						 float *y, 
						 float *flux, 
						 int *npeaks);

/********************************************************************/
IDL_LONG idl_simplexy (int      argc,
                      void *   argv[])
{
	IDL_LONG nx,ny,maxper, maxnpeaks, *npeaks;
	float *image, dpsf, plim, dlim, saddle, *sigma, *x, *y, *flux;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	dpsf=*((float *)argv[i]); i++;
	plim=*((float *)argv[i]); i++;
	dlim=*((float *)argv[i]); i++;
	saddle=*((float *)argv[i]); i++;
	maxper=*((int *)argv[i]); i++;
	maxnpeaks=*((int *)argv[i]); i++;
  sigma=((float *)argv[i]); i++;
  x=((float *)argv[i]); i++;
  y=((float *)argv[i]); i++;
  flux=((float *)argv[i]); i++;
  npeaks=((IDL_LONG *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) simplexy(image, nx, ny, dpsf, plim, dlim, 
														 saddle, maxper, maxnpeaks, sigma,
														 x, y, flux, (int *) npeaks);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

