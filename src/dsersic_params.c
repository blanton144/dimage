#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"

/*
 * dsersic_params.c
 *
 * Translate flux, n, r50 to r0, amp
 * Works (at least) between 0.2<n<6.
 *
 * Mike Blanton
 * 9/2003 */

#define PI 3.1415926535897932384626433832975

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float sp_r0;
static float sp_r50;
static float sp_invn;

float sersic_int(float r)
{
  float val;
  val=2.*PI*r*exp(-pow(r/sp_r0,sp_invn));
  return(val);
}

float sersic_diff(float r0)
{
  float inner,outer;
  sp_r0=r0;
  if(sp_r0<sp_r50) {
    inner=dqromo(sersic_int,0.,sp_r0,dmidpnt)+
      dqromo(sersic_int,sp_r0,sp_r50,dmidpnt);
    outer=dqromo(sersic_int,sp_r50,1.e+30,dmidinf);
  } else {
    inner=dqromo(sersic_int,0.,sp_r50,dmidpnt);
    outer=dqromo(sersic_int,sp_r50,sp_r0,dmidpnt)+
      dqromo(sersic_int,sp_r0,1.e+30,dmidinf);
  }
  return(outer-inner);
}

int dsersic_params(float flux,
									 float n, 
									 float r50,
									 float *amp, 
									 float *r0)
{
  float flux1;

  sp_invn=1./n;
  sp_r50=r50;
  
  (*r0)=dzbrent(sersic_diff,1.e-10*r50,1.e+1*r50,1.e-7);
  sp_r0=(*r0);
  flux1=dqromo(sersic_int,0.,r50,dmidpnt)+
    dqromo(sersic_int,r50,1.e+30,dmidinf);
  (*amp)=flux/flux1;

  return 1;
  
} /* end sersic_params */
