#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "dimage.h"
#include "export.h"

/*
 * deblend.c
 *
 *  Hardwired: level stepping to find saddles for trimming extra template peaks
 *
 * TODO:
 *   model templates and taper them (before trimming or after??)
 *   keep track of template boundaries, and don't bother with analysis outside
 *   remove low significance children
 *
 * Mike Blanton
 * 1/2006 */

#define PI 3.14159265358979

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

#define FREEALL { FREEVEC(fr); FREEVEC(assigned); FREEVEC(stemplates); FREEVEC(invcovar); FREEVEC(weights); FREEVEC(bb); FREEVEC(peak); FREEVEC(xtcen); FREEVEC(ytcen); FREEVEC(mask); FREEVEC(object); FREEVEC(sqnorms); FREEVEC(keep); FREEVEC(pp);}

static float *fr=NULL;
static int *assigned=NULL;
static float *stemplates=NULL;
static float *invcovar=NULL;
static float *weights=NULL;
static float *bb=NULL;
static float *peak=NULL;
static int *xtcen=NULL;
static int *ytcen=NULL;
static int *mask=NULL;
static int *object=NULL;
static float *sqnorms=NULL;
static int *keep=NULL;
static float *pp=NULL;

int deblend(float *image, 
            float *invvar,
						int nx, 
						int ny,
						int *nchild, 
						int *xcen, 
						int *ycen, 
						float *cimages, 
						float *templates, 
            float sigma, 
            float dlim,
            float tsmooth,  /* smoothing of template */
            float tlimit,   /* lowest template value in units of sigma */
            float tfloor,   /* vals < tlimit*sigma are set to tfloor*sigma */
            float saddle,   /* number of sigma for allowed saddle */
            float parallel, /* how parallel you allow templates to be */
						int maxnchild, 
            float minpeak, 
            int starstart, 
						float *psf, 
						int pnx,
						int pny, 
						int dontsettemplates)  
{
  int i,j,k,npeaks,ip,jp,di,dj,ntpeaks,kp,joined,maxiter,niter,
    tmpnpeaks, closest;
  float v1,v2,level,cross,offset,tol,chi2,ss,r2,maxval,val,
    maxlevel, mindist, currdist, tval, tcen;

  printf("in deblend\n"); fflush(stdout);
  mask=(int *) malloc(sizeof(int)*nx*ny);
  object=(int *) malloc(sizeof(int)*nx*ny);
  xtcen=(int *) malloc(sizeof(int)*maxnchild);
  ytcen=(int *) malloc(sizeof(int)*maxnchild);
  printf("%d %d %d\n",nx,ny,maxnchild); fflush(stdout);

  /* 1. find peaks */
  printf("finding peaks.\n"); fflush(stdout);
  if((*nchild)==0) {
    dpeaks(image, nx, ny, &npeaks, xcen, ycen, sigma, dlim, 
           saddle, maxnchild, 1, 1, minpeak,0);
  } else {
    npeaks=(*nchild);
  }
  printf("%d peaks.\n", npeaks); fflush(stdout);

  /* 201.5 find "central" peak */
#if 0
  printf("finding central.\n"); fflush(stdout);
  dcentral(image, nx, ny, npeaks, xcen, ycen, &central, sigma, dlim,
           saddle, maxnchild);
#endif

  /* 2. construct templates */
	if(!dontsettemplates) {
		for(k=0;k<npeaks;k++) {
			
			/* 2a. make a symmetric template */
			printf("making template %d.\n", k);
			for(j=0;j<ny;j++) {
				dj=ycen[k]-j;
				jp=ycen[k]+dj;
				for(i=0;i<nx;i++) {
					di=xcen[k]-i;
					v1=image[i+j*nx];
					ip=xcen[k]+di;
					if(ip>=0 && jp>=0 && ip<nx && jp<ny) {
						v2=image[ip+jp*nx];
						templates[i+j*nx+nx*ny*k]=((v2<v1)?v2:v1); 
						if(v1<1.5*sigma && v2<1.5*sigma) 
							templates[i+j*nx+nx*ny*k]+=0.564189*sigma;
					} else {
						templates[i+j*nx+nx*ny*k]=0.;
					}
				}
			}
			
#if 1 
			/* limit size of stars */ 
			if(k>=starstart) {
				printf("%d %d %d\n", pnx, pny, k-starstart);
				for(j=0;j<ny;j++) 
					for(i=0;i<nx;i++) {
						ip=i-xcen[k]+pnx/2;
						jp=j-ycen[k]+pny/2;
						if(ip>=0 && ip<pnx && jp>0 && jp<pny) 
							templates[i+j*nx+nx*ny*k]=psf[ip+jp*pnx+(k-starstart)*pnx*pny];
						else 
							templates[i+j*nx+nx*ny*k]=0.;
					}
			} else {
#if 0
				printf("smoothing template %d.\n", k);
				stemplates=(float *) malloc(nx*ny*sizeof(float));
				dsmooth(&(templates[k*nx*ny]), nx, ny, tsmooth, stemplates);
				for(j=0;j<ny;j++) 
					for(i=0;i<nx;i++) {
						templates[i+nx*j+nx*ny*k]=stemplates[i+nx*j];
#if 0
						if(templates[i+nx*j+nx*ny*k]< tlimit*sigma)
							templates[i+nx*j+nx*ny*k]=tfloor*sigma;
#endif
					}
				FREEVEC(stemplates);
#endif
			}
#endif
			
#if 0
			/* 2b. now remove smaller peaks from the template */
			printf("finding peaks in template %d.\n", k);
			closest=-1;
			dpeaks(&(templates[nx*ny*k]), nx, ny, &ntpeaks, xtcen, ytcen, sigma, 
						 dlim, saddle, 5, 1, 0, 5.*sigma,0);
			printf("trimming peaks in template %d.\n", k);
			if(ntpeaks>1) {
				mindist=nx*ny;
				for(kp=0;kp<ntpeaks;kp++) {
					currdist=sqrt((xtcen[kp]-xcen[k])*(xtcen[kp]-xcen[k])+
												(ytcen[kp]-ycen[k])*(ytcen[kp]-ycen[k]));
					if(currdist<mindist) {
						closest=kp;
						mindist=currdist;
					}
				}
				for(kp=0;kp<ntpeaks;kp++) {
					
					if(kp!=closest) {
						printf("%d %d %d \n", k, kp, ntpeaks);
						
						/* step up threshold until you separate them */
						maxlevel=templates[(int) xtcen[kp]+(int) ytcen[kp]*nx+k*nx*ny] 
							-2.5*sigma;
						if(maxlevel>1.*sigma) {
							joined=1;
							level=1.*sigma;
							while(joined && level<maxlevel) {
								level+=1.*sigma;
								for(jp=0;jp<ny;jp++)
									for(ip=0;ip<nx;ip++)
										mask[ip+jp*nx]=templates[ip+jp*nx+k*nx*ny]>level;
								dfind(mask, nx, ny, object);
								joined=(object[(int) xtcen[kp]+(int) ytcen[kp]*nx]==
												object[(int) xtcen[closest]+(int) ytcen[closest]*nx]);
							}
							if(level>0 && level<maxlevel) {
								for(jp=0;jp<ny;jp++)
									for(ip=0;ip<nx;ip++)
										mask[ip+jp*nx]=templates[ip+jp*nx+k*nx*ny]>level;
								dfind(mask, nx, ny, object);
								for(jp=0;jp<ny;jp++)
									for(ip=0;ip<nx;ip++)
										if(object[(int) xtcen[kp]+(int) ytcen[kp]*nx]==
											 object[ip+jp*nx]) templates[ip+jp*nx+k*nx*ny]=level;
							}
						}
					}
				}
			}
#endif
		}

  
		/* 2.5 return if there is nothing to deblend */
		if(npeaks<=1) {
			for(j=0;j<ny;j++) 
				for(i=0;i<nx;i++) 
					cimages[i+j*nx]=image[i+j*nx];
			*nchild=npeaks;
			FREEALL;
			return(1);
		}

		/* 3. scale templates */
		peak=(float *) malloc(sizeof(int)*npeaks);
		for(k=0;k<npeaks;k++) {
			peak[k]=0.;
			for(j=0;j<ny;j++) 
				for(i=0;i<nx;i++) 
					if(templates[i+j*nx+k*nx*ny]>peak[k])
						peak[k]=templates[i+j*nx+k*nx*ny];
			for(j=0;j<ny;j++) 
				for(i=0;i<nx;i++) 
					templates[i+j*nx+k*nx*ny]/=peak[k];
		}

		/* 4. check for very parallel templates and get rid */
		printf("npreaks=%d\n", npeaks);
		sqnorms=(float *) malloc(sizeof(float)*npeaks);
		keep=(int *) malloc(sizeof(int)*npeaks);
		for(k=0;k<npeaks;k++) {
			sqnorms[k]=0;
			for(j=0;j<ny;j++) 
				for(i=0;i<nx;i++) 
					sqnorms[k]+=templates[i+j*nx+k*nx*ny]*templates[i+j*nx+k*nx*ny];
		}
		for(k=0;k<npeaks;k++) 
			keep[k]=1;
		for(k=0;k<npeaks;k++) 
			for(kp=k+1;kp<npeaks;kp++) {
				if(k!=kp && keep[k]>0 && keep[kp]>0) {
					cross=0.;
					for(j=0;j<ny;j++) 
						for(i=0;i<nx;i++) 
							cross+=templates[i+j*nx+kp*nx*ny]*templates[i+j*nx+k*nx*ny];
					cross/=sqrt(sqnorms[k]*sqnorms[kp]);
					if(cross>parallel) {
						if(peak[k]>peak[kp]) 
							keep[kp]=0;
						else 
							keep[k]=0;
					}
				}
			}
		tmpnpeaks=0;
		for(k=0;k<npeaks;k++) {
			if(keep[k]) {
				xcen[tmpnpeaks]=xcen[k];
				ycen[tmpnpeaks]=ycen[k];
				for(j=0;j<ny;j++) 
					for(i=0;i<nx;i++) 
						templates[i+j*nx+tmpnpeaks*nx*ny]=templates[i+j*nx+k*nx*ny];
				peak[tmpnpeaks]=peak[k];
				tmpnpeaks++;
			}
		}
		npeaks=tmpnpeaks;
	}
  printf("sdajkfh npreaks=%d\n", npeaks);

  /* 5. solve for child weights */
  invcovar=(float *) malloc(npeaks*npeaks*sizeof(float));
  weights=(float *) malloc(npeaks*sizeof(float));
  bb=(float *) malloc(npeaks*sizeof(float));
	pp=(float *) malloc(npeaks*sizeof(float));
  for(k=0;k<npeaks;k++)
    for(kp=0;kp<npeaks;kp++) {
      invcovar[k+kp*npeaks]=0.;
      for(j=0;j<ny;j++) 
        for(i=0;i<nx;i++) 
          invcovar[k+kp*npeaks]+=templates[i+j*nx+k*nx*ny]*
            templates[i+j*nx+kp*nx*ny] *invvar[i+j*nx];
			printf("%d %d %e %e\n", k, kp, invcovar[k+kp*npeaks], 
						 templates[100+100*nx+k*nx*ny]);
    }
  for(k=0;k<npeaks;k++) {
    bb[k]=0.;
    for(j=0;j<ny;j++) 
      for(i=0;i<nx;i++) 
#if 0
        bb[k]-=templates[i+j*nx+k*nx*ny]*image[i+j*nx] *invvar[i+j*nx] ;
#else 
    bb[k]+=templates[i+j*nx+k*nx*ny]*image[i+j*nx] *invvar[i+j*nx] ;
#endif
  }
  offset=0.;
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) 
      offset+=image[i+j*nx]*image[i+j*nx]*invvar[i+j*nx];
  offset*=0.5;
  maxiter=50000;
  tol=1.e-6;
#if 0
  for(k=0;k<npeaks;k++)
    weights[k]=1./(float)npeaks;
  dnonneg(weights, invcovar, bb, offset, npeaks, tol, maxiter, &niter, 
          &chi2, 0);
#else 
  dcholdc(invcovar,npeaks,pp);
  dcholsl(invcovar,npeaks,pp,bb,weights);
#endif
  for(k=0;k<npeaks;k++)
    printf("%e\n",weights[k]);

  /* 6. find pixel fluxes */

  /* first smooth templates*/
  stemplates=(float *) malloc(nx*ny*npeaks*sizeof(float));
  printf("blah\n"); fflush(stdout);
	kp=0;
  for(k=0;k<npeaks;k++) {
		if(weights[k]>1.e-10) {
			dsmooth(&(templates[k*nx*ny]), nx, ny, 4., &(stemplates[kp*nx*ny]));
			for(j=0;j<ny;j++) 
				for(i=0;i<nx;i++) 
					templates[i+j*nx+kp*nx*ny]=templates[i+j*nx+k*nx*ny];
			kp++;
		}
	}
	npeaks=kp;
  printf("blah %d\n", npeaks); fflush(stdout);
  assigned=(int *)malloc(nx*ny*sizeof(int));
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) 
      assigned[i+j*nx]=0;
  printf("blah\n"); fflush(stdout);
  for(j=0;j<ny;j++) 
    for(i=0;i<nx;i++) {
      ss=0.;
      for(k=0;k<npeaks;k++)
        ss+=weights[k]*templates[i+j*nx+nx*ny*k];
      if(ss>5.*sigma) {
        for(k=0;k<npeaks;k++)
          cimages[i+j*nx+nx*ny*k]= 
            image[i+j*nx]*weights[k]*templates[i+j*nx+nx*ny*k]/ss;
        assigned[i+nx*j]=1;
      } else {
        ss=0.;
        for(k=0;k<npeaks;k++)
          ss+=weights[k]*stemplates[i+j*nx+nx*ny*k];
        if(ss>0.5*sigma) {
          for(k=0;k<npeaks;k++)
            cimages[i+j*nx+nx*ny*k]= 
              image[i+j*nx]*weights[k]*stemplates[i+j*nx+nx*ny*k]/ss;
          assigned[i+nx*j]=1;
        }
      }
    }
#if 1
  fr=(float *) malloc(npeaks*sizeof(float));
  for(k=0;k<npeaks;k++) {
    fr[k]=0.;
    for(j=0;j<ny;j++)
      for(i=0;i<nx;i++) {
        r2=((float) i - xcen[k])*((float) i - xcen[k])+
          ((float) j - ycen[k])*((float) j - ycen[k]);
        fr[k]+=cimages[i+j*nx+k*nx*ny]*r2;
      }
  }
  for(j=0;j<ny;j++)
    for(i=0;i<nx;i++) {
      if(!assigned[i+nx*j]) {
        maxval=-1.;
        kp=-1;
        for(k=0;k<npeaks;k++) {
          r2=((float) i - xcen[k])*((float) i - xcen[k])+
            ((float) j - ycen[k])*((float) j - ycen[k]);
          val=fr[k]/r2;
          if(val>maxval) {
            maxval=val;
            kp=k;
          }
        }
        cimages[i+j*nx+kp*nx*ny]=image[i+j*nx];
      }
    }
#endif
    
  *nchild=npeaks;

  FREEALL;

	return(1);
} /* end deblend */

