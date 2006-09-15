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
IDL_LONG idl_dfluxes(int      argc,
                     void *   argv[])
{
	IDL_LONG nx,ny,nchild;
	float *image, *templates, *weights, *children, sigma, *xcen, *ycen;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	templates=((float *)argv[i]); i++;
	weights=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	xcen=((float *)argv[i]); i++;
	ycen=((float *)argv[i]); i++;
	nchild=*((IDL_LONG *)argv[i]); i++;
	children=((float *)argv[i]); i++;
	sigma=*((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dfluxes(image, templates, weights, (int) nx, (int) ny, 
                            xcen, ycen, (int) nchild, children, sigma);
                            
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

