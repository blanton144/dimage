#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dfitpsf(float *atlas, float *atlas_ivar, int nx, int ny, int nim, 
            float *psfc, float *psft, float *xpsf, float *ypsf, int nc, 
            int np);

/********************************************************************/
IDL_LONG idl_dfitpsf (int      argc,
                      void *   argv[])
{
	IDL_LONG nx,ny,nc,np,nim;
	float *atlas, *atlas_ivar, *psft, *psfc, *xpsf, *ypsf;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	atlas=((float *)argv[i]); i++;
	atlas_ivar=((float *)argv[i]); i++;
	nx=*((IDL_LONG *)argv[i]); i++;
	ny=*((IDL_LONG *)argv[i]); i++;
	nim=*((IDL_LONG *)argv[i]); i++;
  psfc=((float *)argv[i]); i++;
  psft=((float *)argv[i]); i++;
  xpsf=((float *)argv[i]); i++;
  ypsf=((float *)argv[i]); i++;
  nc=*((IDL_LONG *)argv[i]); i++;
  np=*((IDL_LONG *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dfitpsf(atlas, atlas_ivar, (int) nx, (int) ny, (int) nim,
                            psfc, psft, xpsf, ypsf, (int) nc, (int) np);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

