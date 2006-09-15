#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dfind(int *image, int nx, int ny, int *object);

/********************************************************************/
IDL_LONG idl_dfind (int      argc,
                    void *   argv[])
{
	IDL_LONG nx,ny,*object, *image;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((IDL_LONG *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	object=((IDL_LONG *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dfind((int *) image, nx, ny, (int *) object);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

