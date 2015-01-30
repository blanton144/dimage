#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "export.h"
#include "dimage.h"

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

IDL_LONG idl_dshift (int      argc,
										 void *   argv[])
{
	IDL_LONG nx,ny, ktype;
	float *image, dx, dy;
	
	IDL_LONG i, nk;
	IDL_LONG retval=1;
	float (*kernel)(float);
	
	
	/* 0. allocate pointers from IDL */
	i=0;
	image=((float *)argv[i]); i++;
	nx=*((int *)argv[i]); i++;
	ny=*((int *)argv[i]); i++;
	ktype=*((int *)argv[i]); i++;
	dx=*((float *)argv[i]); i++;
	dy=*((float *)argv[i]); i++;
	
	/* which interpolation? */
	if(ktype==0) {
		kernel= dkernel_linear;
		nk= dkernel_linear_size();
	} else if(ktype==1) {
		kernel= dkernel_puresinc;
		nk= dkernel_puresinc_size();
	} else if(ktype==2) {
		kernel= dkernel_dampsinc;
		nk= dkernel_dampsinc_size();
	} else if(ktype==3) {
		kernel= dkernel_bicubic;
		nk= dkernel_bicubic_size();
	} else {
		printf("No such kernel type: %ld\n", ktype);
		printf("Possible values:\n");
		printf(" 0 - linear (not recommended)\n");
		printf(" 1 - pure sinc (not recommended)\n");
		printf(" 2 - damped sinc (* recommended work horse)\n");
		printf(" 3 - bicubic sinc (* recommended for speed)\n");
		return 1;
	}
	
	/* 1. run the shifting routine */
	dshift(image, nx, ny, dx, dy, kernel, nk);
	
	/* 2. free memory and leave */
	return retval;
}

/***************************************************************************/

