#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dkernel_bicubic.c
 *
 * Kernel for damped sinc interpolation 
 *
 * Mike Blanton
 * 10/2009 */

#define PI 3.14159265358979
#define AA (-0.5)

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int dkernel_bicubic_size() {
	return(5);
} /* end dkernel_bicubic_size */

float dkernel_bicubic(float dx)
{
	float val;

	if(dx<=-2. || dx>=2) return(0.);
	
	if(fabs(dx)< 1.) {
		val= (AA+2.)*fabs(dx*dx*dx)-(AA+3.)*dx*dx+1.;
	} else {
		val= AA*fabs(dx*dx*dx)-5.*AA*dx*dx+8.*AA*fabs(dx)-4.*AA;
	}
	
	return(val);
	
} /* end dkernel_bicubic */


