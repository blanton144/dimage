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
IDL_LONG idl_dobjects (int      argc,
											void *   argv[])
{
	IDL_LONG nx,ny, *objects;
	float *image, dpsf, plim, *smooth;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	smooth=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	dpsf=*((float *)argv[i]); i++;
	plim=*((float *)argv[i]); i++;
	objects=((IDL_LONG *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dobjects(image, smooth, nx, ny, dpsf, plim, 
                             (int *) objects);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

