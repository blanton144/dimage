#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"
#include "dimage.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}


/********************************************************************/
IDL_LONG idl_dpeaks (int      argc,
                     void *   argv[])
{
	IDL_LONG nx,ny,*npeaks,maxnpeaks, checkpeaks, smooth, *xcen, *ycen;
	float *image, dlim, sigma, saddle, minpeak;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
  npeaks=((IDL_LONG *)argv[i]); i++;
  xcen=((IDL_LONG *)argv[i]); i++;
  ycen=((IDL_LONG *)argv[i]); i++;
  sigma=*((float *)argv[i]); i++;
  dlim=*((float *)argv[i]); i++;
  saddle=*((float *)argv[i]); i++;
  maxnpeaks=*((int *)argv[i]); i++;
  smooth=*((int *)argv[i]); i++;
  checkpeaks=*((int *)argv[i]); i++;
  minpeak=*((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dpeaks(image, nx, ny, (int *) npeaks, (int *) xcen, 
													 (int *) ycen, sigma,
                           dlim, saddle, maxnpeaks, smooth, checkpeaks, 
													 minpeak);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

