#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dmsmooth(float *image, int nx, int ny, int box, float *smooth);

/********************************************************************/
IDL_LONG idl_dmsmooth (int      argc,
                      void *   argv[])
{
	IDL_LONG nx,ny,box;
	float *image, *smooth;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
  box=*((int *)argv[i]); i++;
  smooth=((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dmsmooth(image, nx, ny, box, smooth);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

