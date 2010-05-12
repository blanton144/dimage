#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dkernel_linear.c
 *
 * Kernel for linear interpolation.
 *
 * Mike Blanton
 * 10/2009 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int dkernel_linear_size() {
	return(3);
} /* end dkernel_linear_size */

float dkernel_linear(float dx)
{
	if(dx<-1. || dx>1.) return(0.);
	return (1.-fabs(dx));
	
} /* end dkernel_linear */


