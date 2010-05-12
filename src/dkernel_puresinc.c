#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dkernel_puresinc.c
 *
 * Kernel for pure sinc interpolation (NEVER recommended)
 *
 * Mike Blanton
 * 10/2009 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int dkernel_puresinc_size() {
	return(201);
} /* end dkernel_puresinc_size */

float dkernel_puresinc(float dx)
{
	float val;

	if(dx<=-100.5 || dx>=100.5) return(0.);
	if(fabs(dx)<1.e-6) return(1.);
	val= sin(dx*PI)/(dx*PI);
	return(val);
	
} /* end dkernel_puresinc */


