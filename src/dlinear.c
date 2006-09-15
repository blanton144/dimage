#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
 * dlinear.c
 *
 * solve a linear chi^2 problem using the multiplication update 
 * technique
 *  From some starting point, iterates to convergence a
 *  box-constrained QP problem: 
 *
 *     F(v) = (1/2) v^T.A.v + b^T.v for v_i >= 0 for all i.
 *
 *  Uses the method of Sha, Saul, & Lee (2002), "Multiplicative
 *  updates for nonnegative quadratic programming in support vector
 *  machines" (UPenn Tech Report MS-CIS-02-19). Look on google.
 *
 *  It requires the user to supply a matrix A (called invcovar in the
 *  code), which gets turned into A+ and A- where:
 *  
 *     A+_ij = A_ij for A_ij>0.
 *             0.   otherwise
 *
 *     A-_ij = |A_ij|  for A_ij<0.
 *             0.      otherwise
 *
 * Inputs are:
 *   invcovar  --> "A" (square matrix)
 *   bb        --> "b"
 *   offset    --> offset term to convert F(v) to a reasonable chi^2
 *   nn        --> number params in "b"
 *   tolerance --> convergence criterion in chi^2
 *   maxiter   --> maximum number of iters
 *   verbose   --> make noise?
 * Output are:
 *   xx        --> best fit "v"
 *   niter     --> number of iters
 *   chi2      --> chi^2 of output
 *
 * Mike Blanton
 * 5/2003 */
 
#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float *invcovar_pos=NULL;
static float *invcovar_neg=NULL;

/* update at each iteration step */
int dnonneg_update(float *xx,
                        float *invcovar,
                        float *bb,
                        int nn)
{
	int i,j;

	for(i=0;i<nn;i++) {
		invcovar_pos[i]=0.;
		invcovar_neg[i]=0.;
		for(j=0;j<nn;j++) 
			if(invcovar[i*nn+j]>0.) 
				invcovar_pos[i]+=invcovar[i*nn+j]*xx[j];
			else 
				invcovar_neg[i]-=invcovar[i*nn+j]*xx[j];
	} /* end for i */

	for(i=0;i<nn;i++) 
		if(xx[i]>0.) 
			xx[i]*=(-bb[i]+sqrt(bb[i]*bb[i]+4.*invcovar_pos[i]*invcovar_neg[i]))/ 
				(2.*invcovar_pos[i]);

	return(1);
} /* end dnonneg_update */

/* calculate chi^2 */ 
float dnonneg_chi2(float *xx,
										 float *invcovar,
										 float *bb,
										 float offset,
										 int nn)
{
	int i,j;
	float chi2;

	chi2=0.;
	for(i=0;i<nn;i++) 
		for(j=0;j<nn;j++) 
			chi2+=invcovar[i*nn+j]*xx[i]*xx[j];
	for(i=0;i<nn;i++) 
		chi2+=2.*xx[i]*bb[i];
	chi2+=2.*offset;

	return(chi2);
} /* end dnonneg_update */

/* perform the iteration */
int dnonneg(float *xx,
            float *invcovar,
            float *bb,
            float offset,
            int nn,
            float tolerance, 
            int maxiter,
            int *niter,
            float *chi2,
            int verbose)
{
	float diff,oldval,newval;
	int skip=1000;

	invcovar_pos=(float *) malloc(nn*nn*sizeof(float));
	invcovar_neg=(float *) malloc(nn*nn*sizeof(float));
	diff=tolerance*2.;
	newval=dnonneg_chi2(xx,invcovar,bb,offset,nn);
	oldval=newval+diff;
	(*niter)=0;
	while((*niter)<maxiter && diff>tolerance) {
		dnonneg_update(xx,invcovar,bb,nn);
		if((*niter)%skip == 0 && verbose) {
			newval=dnonneg_chi2(xx,invcovar,bb,offset,nn);
			printf("niter=%d ; chi2=%e\n",*niter,newval);
			diff=oldval-newval;
			oldval=newval;
		} /* end if */
		(*niter)++;
	} /* end while*/
	newval=dnonneg_chi2(xx,invcovar,bb,offset,nn);
	if(verbose) printf("niter=%d ; chi2=%e\n",*niter,newval);
	(*chi2)=newval;
	FREEVEC(invcovar_pos);
	FREEVEC(invcovar_neg);

	return(1);
} /* end dnonneg_solve */
