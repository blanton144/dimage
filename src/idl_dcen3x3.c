#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dcen3x3(float *image, float *xcen, float *ycen);

/********************************************************************/
IDL_LONG idl_dcen3x3 (int      argc,
                      void *   argv[])
{
	float *image, *xcen, *ycen;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
  xcen=((float *)argv[i]); i++;
  ycen=((float *)argv[i]); i++;
	
	/* 1. run the fitting routine */
	retval=(IDL_LONG) dcen3x3(image, xcen, ycen);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

