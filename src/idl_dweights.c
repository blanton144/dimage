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
IDL_LONG idl_dweights(int      argc,
                      void *   argv[])
{
	IDL_LONG nx,ny,ntemplates, nonneg;
	float *image, *templates, *invvar, *weights;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	invvar=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	ntemplates=*((IDL_LONG *)argv[i]); i++;
	templates=((float *)argv[i]); i++;
	nonneg=*((IDL_LONG *)argv[i]); i++;
	weights=((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dweights(image, invvar, nx, ny, (int ) ntemplates, 
                             (float *) templates, (int) nonneg, 
                             (float *) weights);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

