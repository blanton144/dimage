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
IDL_LONG idl_dtemplates (int      argc,
												 void *   argv[])
{
	IDL_LONG nx,ny,*nchild, *ntemplates, *xcen, *ycen;
	float *image, *templates, parallel, sigma;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	ntemplates=((IDL_LONG *)argv[i]); i++;
	xcen=((IDL_LONG *)argv[i]); i++;
	ycen=((IDL_LONG *)argv[i]); i++;
	templates=((float *)argv[i]); i++;
	sigma=*((float *)argv[i]); i++;
	parallel=*((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dtemplates(image, nx, ny, (int *) ntemplates, 
															 (int *) xcen, (int *) ycen, templates, 
															 sigma, parallel);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

