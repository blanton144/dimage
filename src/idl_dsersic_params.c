#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "dimage.h"
#include "export.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}
static void free_memory()
{
}

int dsersic_params(float flux, float n, float r50, float *amp, float *r0);

/********************************************************************/
IDL_LONG idl_dsersic_params (int      argc,
														 void *   argv[])
{
	float flux, n, r50, *amp, *r0;
	
	IDL_LONG i;
	IDL_LONG retval=1;

	/* 0. allocate pointers from IDL */
	i=0;
	flux=*((float *)argv[i]); i++;
	n=*((float *)argv[i]); i++;
	r50=*((float *)argv[i]); i++;
	amp=(float *)argv[i]; i++;
	r0=(float *)argv[i]; i++;
	
	/* 1. run the routine */
	retval=dsersic_params(flux, n, r50, amp, r0);
	
	/* 2. free memory and leave */
	free_memory();
	return retval;
}

/***************************************************************************/

