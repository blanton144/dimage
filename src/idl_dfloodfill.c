#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dfloodfill(int *image, int nx, int ny, int x, int y, int xst, int xnd, 
							 int yst, int ynd, int nv);

/********************************************************************/
IDL_LONG idl_dfloodfill (int      argc,
												 void *   argv[])
{
	IDL_LONG nx,ny, x, y, xst, xnd, yst, ynd, nv;
	IDL_LONG *image;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((IDL_LONG *)argv[i]); i++;
	nx=*((IDL_LONG *)argv[i]); i++;
	ny=*((IDL_LONG *)argv[i]); i++;
	x=*((IDL_LONG *)argv[i]); i++;
	y=*((IDL_LONG *)argv[i]); i++;
	xst=*((IDL_LONG *)argv[i]); i++;
	xnd=*((IDL_LONG *)argv[i]); i++;
	yst=*((IDL_LONG *)argv[i]); i++;
	ynd=*((IDL_LONG *)argv[i]); i++;
	nv=*((IDL_LONG *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dfloodfill((int *) image, (int) nx, (int) ny, 
															 (int) x, (int) y, (int) xst, (int) xnd, 
															 (int) yst, (int) ynd, (int) nv);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

