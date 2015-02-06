#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/param.h>

/*
 * dkernel_Lanczos.c
 *
 * Kernel for Lanczos interpolation.
 *
 * Mike Blanton
 * 2/2015 */

#define PI 3.14159265358979

static float alanczos=2.;
static float invalanczos=0.5;

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int dkernel_lanczos_scale(float scale) {
	alanczos=scale;
	invalanczos=1./alanczos;
	return 0;
} /* end dkernel_lanczos_scale */

int dkernel_lanczos_size() {
	return((int)(floor(alanczos)*2+1));
} /* end dkernel_lanczos_size */

float dkernel_lanczos(float dx)
{
	float val;

	if(dx<(-alanczos-1.e-6) || dx>(alanczos+1.e-6)) return(0.);
	if(fabs(dx)<1.e-6) return(1.);
	val= alanczos*sin(dx*PI)*sin(dx*PI*invalanczos)/
		(dx*dx*PI*PI);
	return(val);
} /* end dkernel_lanczos */


