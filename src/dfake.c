#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"

/*
 * dfake.c
 *
 * Create pixel convolved fake Sersic galaxy with unit flux given 
 *   r50, n, b/a, and phi0, as well as xcen and ycen (defined with 
 *   integer values at pixel centersi).
 *
 * Range of trustability at 1% total flux level:
 * 
 *  r50*b/a > 0.05
 *  b/a > 0.15
 *  0.5<n<4.5
 *
 * Mike Blanton
 * 9/2003 */

#define PI 3.1415926535897932384626433832975
#define NRAD 3000
#define TOL 1.e-2

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static int *impos=NULL;
static float exact,fg_j,fg_x,interpscale,fg_xcen,fg_ycen,fg_amp,fg_n,fg_r0;
static float alpha, beta, gmma, delj;
static float radii2[NRAD], values[NRAD], *imrad2=NULL;

float fake_radius2(float x, 
                   float y)
{
  float xoff,yoff;
  xoff=x-fg_xcen;
  yoff=y-fg_ycen;
  return(alpha*xoff*xoff-2.*beta*xoff*yoff+gmma*yoff*yoff);
}

float fginty(float y)
{
  int i,ip1;
  float rad2,sp;
  rad2=fake_radius2(fg_x,y);
  if(exact) return(fg_amp*exp(-pow(rad2/(fg_r0*fg_r0), 1./(fg_n*2.))));
	i=(int) floor((rad2-radii2[0])*interpscale);
	if(i>=NRAD-1) return(values[NRAD-1]);
	if(i<0) return(values[0]);
	ip1=i+1;
	sp=rad2-radii2[i];
	return(fg_amp*
         exp(values[i]+sp*(values[ip1]-values[i])/(radii2[ip1]-radii2[i])));
}

float fgintx(float x)
{
  fg_x=x;
  return(dqromo(fginty,fg_j-delj,fg_j+delj,dmidpnt));
}

int fgcomp(const void *a, const void *b)
{
  if(imrad2[*((int *) a)] < imrad2[*((int*) b)]) return(-1);
  if(imrad2[*((int *) a)] > imrad2[*((int*) b)]) return(1);
  return(0);
}

int dfake(float *image, 
					int nx, 
					int ny, 
					float xcen, 
					float ycen,
					float n,
					float r50,
					float ba,
					float phi0, 
          int simple) 
{
  float oldim,amp,r0,sinph0,cosph0,ab2,d2r,r2;
  int i,j,k,inner,cont;

  inner=ceil(r50);
  if(inner<1) inner=1;
  if(inner>8) inner=8;

  /* translate r50,n,f=1 to r0,n,amp */
  dsersic_params(1.,n,r50,&amp,&r0);
  amp/=ba;
  fg_amp=amp;
  fg_r0=r0;
  fg_n=n;
  
  /* determine some global numbers */
  fg_xcen=xcen;
  fg_ycen=ycen;
  ab2=1./ba/ba;
  d2r=PI/180.;
  sinph0=sin(phi0*d2r);
  cosph0=cos(phi0*d2r);
  alpha=1.+(ab2-1.)*sinph0*sinph0;
  beta=(ab2-1.)*sinph0*cosph0;
  gmma=1.+(ab2-1.)*cosph0*cosph0;

  /* go to each pixel and just evaluate */
  for(i=0;i<nx;i++) 
    for(j=0;j<ny;j++) {
      r2=fake_radius2((float) i, (float) j);
      image[j*nx+i]=amp*exp(-pow(r2/(r0*r0), 1./(n*2.)));
    } /* end for i j */

  if(simple==0) {
    /* now look at inner pixels and integrate em */
    imrad2=(float *) malloc(nx*ny*sizeof(float));
    impos=(int *) malloc(nx*ny*sizeof(int));
    for(i=0;i<nx;i++) 
      for(j=0;j<ny;j++) {
        impos[j*nx+i]=j*nx+i;
        imrad2[j*nx+i]=fake_radius2((float) i, (float) j);
      }
    qsort(impos,nx*ny,sizeof(int),fgcomp);
    cont=1;
    for(k=0;(k<36 && cont) || k<16;k++) {
      i=impos[k]%nx;
      j=impos[k]/nx;
      oldim=image[j*nx+i];
      if(i==floor(xcen+0.5) && j==floor(ycen+0.5)) {
        exact=1;
        delj=0.25;
        fg_j=(float) j - 0.25;
        image[j*nx+i]=dqromo2(fgintx,(float)i-0.5, (float) i, dmidpnt2);
        image[j*nx+i]+=dqromo2(fgintx,(float) i, (float)i+0.5, dmidpnt2);
        fg_j=(float) j + 0.25;
        image[j*nx+i]+=dqromo2(fgintx,(float)i-0.5, (float)i, dmidpnt2);
        image[j*nx+i]+=dqromo2(fgintx,(float)i, (float)i+0.5, dmidpnt2);
      } else {
        delj=0.5;
        exact=1;
        fg_j=(float) j;
        image[j*nx+i]=dqromo2(fgintx,(float)i-0.5, (float)i+0.5, dmidpnt2);
      }
      if(fabs(oldim-image[j*nx+i])<1.e-5) cont=0;
    }
  }
  
  FREEVEC(imrad2);
  FREEVEC(impos);
  return(0);

} /* end dfake */
