#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
 * nmf.c
 *
 * Mike Blanton
 * 2/2006 */
 
#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float *datap=NULL;
static float *datahat=NULL;
static float *datahatp=NULL;

float dran3(long *idum);

int nmf(float *data,
        float *ivar,
        int ndata,
        int nim, 
        float *coeffs,
        float *templates,
        int nc)
{
  int i,k,c,iters, maxiters;
  long seed;
  float tot, err, eold, tol, cnumer, cdenom, tnumer, tdenom;

  maxiters=10000;
  tol=1.e-6;
  
  printf("blah\n"); fflush(stdout);
  datap=(float *) malloc(ndata*nim*sizeof(float));
  datahat=(float *) malloc(ndata*nim*sizeof(float));
  datahatp=(float *) malloc(ndata*nim*sizeof(float));

  for(k=0;k<nim;k++)
    for(i=0;i<ndata;i++)
      datap[i+k*ndata]=data[i+k*ndata]*ivar[i+k*ndata];

  printf("blah\n"); fflush(stdout);
  seed=-1;
  for(c=0;c<nc;c++) {
    for(i=0;i<ndata;i++)
      templates[i+c*ndata]=0.5+dran3(&seed);
    tot=0.;
    for(i=0;i<ndata;i++)
      tot+=templates[i+c*ndata];
    for(i=0;i<ndata;i++)
      templates[i+c*ndata]/=tot;
  }

  for(c=0;c<nc;c++) {
    for(k=0;k<nim;k++) {
      coeffs[k*nc+c]=0.;
      for(i=0;i<ndata;i++)
        coeffs[k*nc+c]+=templates[i+c*ndata]*data[i+k*ndata]; 
    }
  }
  printf("blah\n"); fflush(stdout);

  for(i=0;i<ndata;i++) {
      for(k=0;k<nim;k++) {
        datahat[i+k*ndata]=0.;
        for(c=0;c<nc;c++) {
          datahat[i+k*ndata]+=templates[i+c*ndata]*coeffs[k*nc+c]; 
        }
      }
    }
  
  err=1.e+19;
  eold=1.e+20;
  iters=1;

  printf("blah\n"); fflush(stdout);
  while(iters<maxiters && fabs(err-eold)/err>tol) {
    
    printf("iters=%d\n", iters); fflush(stdout);
    
    for(k=0;k<nim;k++)
      for(i=0;i<ndata;i++)
        datahatp[i+k*ndata]=datahat[i+k*ndata]*ivar[i+k*ndata];
    
    for(c=0;c<nc;c++) {
      for(k=0;k<nim;k++) {
        cnumer=0.;
        for(i=0;i<ndata;i++)
          cnumer+=templates[i+c*ndata]*datap[i+k*ndata];
        cdenom=0.;
        for(i=0;i<ndata;i++)
          cdenom+=templates[i+c*ndata]*datahatp[i+k*ndata];
        coeffs[k*nc+c]*=cnumer/cdenom;
      }
    }
    
    for(c=0;c<nc;c++) {
      for(i=0;i<ndata;i++) {
        tnumer=0.;
        for(k=0;k<nim;k++) 
          tnumer+=coeffs[k*nc+c]*datap[i+k*ndata];
        tdenom=0.;
        for(k=0;k<nim;k++) 
          tdenom+=coeffs[k*nc+c]*datahatp[i+k*ndata];
        templates[i+c*ndata]*=tnumer/tdenom;
      }
    }

    for(c=0;c<nc;c++) {
      tot=0.;
      for(i=0;i<ndata;i++)
        tot+=templates[i+c*ndata];
      for(i=0;i<ndata;i++)
        templates[i+c*ndata]/=tot;
    }

    for(i=0;i<ndata;i++) {
      for(k=0;k<nim;k++) {
        datahat[i+k*ndata]=0.;
        for(c=0;c<nc;c++) {
          datahat[i+ndata*k]+=templates[i+c*ndata]*coeffs[k*nc+c]; 
        }
      }
    }

    eold=err;
    err=0.;
    for(k=0;k<nim;k++) {
      for(i=0;i<ndata;i++) {
          err+=(datahat[i+k*ndata]-data[i+k*ndata])*
            (datahat[i+k*ndata]-data[i+k*ndata])*
            ivar[i+k*ndata];
      }
    }

    printf("err=%e\n", err); fflush(stdout);
    iters++;
  }
  
  FREEVEC(datap);
  FREEVEC(datahat);
  FREEVEC(datahatp);

	return(1);
} /* end nmf */
