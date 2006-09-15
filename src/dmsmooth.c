#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
 * dmsmooth.c
 *
 * Median smooth an image
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float *arr=NULL;

float dselip(unsigned long k, unsigned long n, float *arr);

int dmsmooth(float *image, 
             int nx, 
             int ny,
             int box,
             float *smooth)
{
  int i,j,half,ip,jp,ist,jst,nxt,nyt,nb,ind,jnd,ioff,joff,nm;

  arr=(float *) malloc((box+4)*(box+4)*sizeof(float));
  half=box/2;

  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) 
      smooth[i+j*nx]=0.;

  for(j=0;j<ny;j++) {
    jst=j-half;
    jnd=j+half;
    if(jst<0) jst=0;
    if(jnd>ny-1) jnd=ny-1;
    nyt=jnd-jst+1;
    for(i=0;i<nx;i++) {
      ist=i-half;
      ind=i+half;
      if(ist<0) ist=0;
      if(ind>nx-1) ind=nx-1;
      nxt=ind-ist+1;
      nb=nxt*nyt;
      for(jp=jst;jp<=jnd;jp++) 
        for(ip=ist;ip<=ind;ip++) {
          ioff=ip-ist;
          joff=jp-jst;
          arr[ioff+joff*nxt]=image[ip+jp*nx];
        }
      nm=nb/2;
      smooth[i+j*nx]=dselip(nm,nb,arr);
    }
  }
  
  FREEVEC(arr);
  
	return(1);
} /* end photfrac */
