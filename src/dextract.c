#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"

/*
 * dextract.c
 *
 * Take image and list of objects, and produce list of all peaks 
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float *smooth=NULL;
static int *peaks=NULL;
static int *indx=NULL;
static int *object=NULL;
static int *keep=NULL;
static int *mask=NULL;
static float *fullxcen=NULL;
static float *fullycen=NULL;

int dpeaks_compare(const void *first, const void *second)
{
  float v1,v2;
  v1=smooth[peaks[*((int *) first)]];
  v2=smooth[peaks[*((int *) second)]];
  if(v1>v2) return(-1);
  if(v1<v2) return(1);
  return(0);
}

int dsmooth(float *image, int nx, int ny, float sigma, float *smooth);

int dfind(int *image, int nx, int ny, int *object);

int dpeaks(float *image, 
           int nx, 
           int ny,
           int *npeaks, 
           float *xcen, 
           float *ycen, 
           float sigma,   /* sky sigma */
           float dlim,    /* limiting distance */
           float saddle,  /* number of sigma for allowed saddle */
           int maxnpeaks, 
           int smoothimage, 
           float minpeak)
{
  int i,j,ip,jp,ist,jst,ind,jnd,highest,tmpnpeaks;
  float dx,dy, level;

  printf("%e %e %e\n", sigma, dlim, saddle);
  
  /* 1. smooth image */
  smooth=(float *) malloc(sizeof(float)*nx*ny);
  if(smoothimage) {
    dsmooth(image, nx, ny, 2, smooth);
  } else {
    for(j=0;j<ny;j++) 
      for(i=0;i<nx;i++) 
        smooth[i+j*nx]=image[i+j*nx];
  }

  /* 2. find peaks */ 
  peaks=(int *) malloc(sizeof(int)*nx*ny);
  *npeaks=0;
  for(j=1;j<ny-1;j++) {
    jst=j-1;
    jnd=j+1;
    for(i=1;i<nx-1;i++) {
      ist=i-1;
      ind=i+1;
      if(smooth[i+j*nx]>minpeak) {
        highest=1;
        for(ip=ist;ip<=ind;ip++)
          for(jp=jst;jp<=jnd;jp++)
            if(smooth[ip+jp*nx]>smooth[i+j*nx])
              highest=0;
        if(highest) {
          peaks[*npeaks]=i+j*nx;
          (*npeaks)++;
        }
      }
    }
  }

  /* 2. sort peaks */
  printf("%d peaks\n", (*npeaks));
  indx=(int *) malloc(sizeof(int)*(*npeaks));
  for(i=0;i<(*npeaks);i++)
    indx[i]=i;
  qsort((void *) indx, (*npeaks), sizeof(int), dpeaks_compare);
  if((*npeaks)>100*maxnpeaks) *npeaks=100*maxnpeaks;
  fullxcen=(float *) malloc((*npeaks)*sizeof(float));
  fullycen=(float *) malloc((*npeaks)*sizeof(float));
  for(i=0;i<(*npeaks);i++) {
    fullxcen[i]=peaks[indx[i]]%nx;
    fullycen[i]=peaks[indx[i]]/nx;
  }

  /* 3. trim close peaks and joined peaks */
  mask=(int *) malloc(sizeof(int)*nx*ny);
  object=(int *) malloc(sizeof(int)*nx*ny);
  keep=(int *) malloc(sizeof(int)*(*npeaks));
  for(i=(*npeaks)-1;i>=0;i--) {
    keep[i]=1;

    /* look for peaks joined by a high saddle to brighter peaks */
    level= (smooth[(int) fullxcen[i]+ (int) fullycen[i]*nx]-saddle*sigma);
    if(level<saddle*sigma) 
      level=(smooth[(int) fullxcen[i]+ (int) fullycen[i]*nx]-sigma);
    for(jp=0;jp<ny;jp++)
      for(ip=0;ip<nx;ip++)
        mask[ip+jp*nx]=smooth[ip+jp*nx]>level;
    dfind(mask, nx, ny, object);
    for(j=i-1;j>=0;j--) 
      if(object[(int) fullxcen[j]+(int) fullycen[j]*nx]==
         object[(int) fullxcen[i]+(int) fullycen[i]*nx] || 
         object[(int) fullxcen[i]+(int) fullycen[i]*nx]==-1 ) {
        keep[i]=0;
      }

    /* look for close peaks */
    for(j=i-1;j>=0;j--) {
      dx=fullxcen[j]-fullxcen[i];
      dy=fullycen[j]-fullycen[i];
      if(dx*dx+dy*dy<dlim*dlim)
        keep[i]=0;
    }
  }
  
  tmpnpeaks=0;
  for(i=0;i<(*npeaks);i++) {
    if(keep[i] && tmpnpeaks<maxnpeaks) {
      xcen[tmpnpeaks]=fullxcen[i];
      ycen[tmpnpeaks]=fullycen[i];
      tmpnpeaks++;
    } 
  }
  (*npeaks)=tmpnpeaks;

  FREEVEC(smooth);
  FREEVEC(peaks);
  FREEVEC(keep);
  FREEVEC(indx);
  FREEVEC(object);
  FREEVEC(mask);
  FREEVEC(fullxcen);
  FREEVEC(fullycen);
  
	return(1);
} /* end dpeaks */
