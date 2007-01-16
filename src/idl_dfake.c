#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "dimage.h"
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dfake(float *image, int nx, int ny, float xcen, float ycen,
					float n, float r50, float ba, float phi0, int simple); 

/********************************************************************/
IDL_LONG idl_dfake (int      argc,
                          void *   argv[])
{
  IDL_LONG nx,ny, simple;
	float *image, n, r50, ba, phi0, xcen, ycen;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	xcen=*((float *)argv[i]); i++;
	ycen=*((float *)argv[i]); i++;
	n=*((float *)argv[i]); i++;
	r50=*((float *)argv[i]); i++;
	ba=*(float *)argv[i]; i++;
	phi0=*(float *)argv[i]; i++;
	simple=*(int *)argv[i]; i++;
	
	/* 1. run the fitting routine */
	retval=dfake(image,nx,ny,xcen,ycen,n,r50,ba,phi0, simple);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

