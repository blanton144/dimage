#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dkernel_dampsinc.c
 *
 * Kernel for damped sinc interpolation 
 *
 * Mike Blanton
 * 10/2009 */

#define PI 3.14159265358979
#define INVSIG2 (0.1632)

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int dkernel_dampsinc_size() {
	return(21);
} /* end dkernel_dampsinc_size */

float dkernel_dampsinc(float dx)
{
	float val;

	if(dx<=-10.5 || dx>=10.5) return(0.);
	if(fabs(dx)<1.e-6) return(1.);
	val= sin(dx*PI)/(dx*PI)*exp(-0.5*dx*dx*INVSIG2);
	return(val);
	
} /* end dkernel_dampsinc */


