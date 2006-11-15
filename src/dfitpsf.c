#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
 * dfitpsf.c
 *
 * Deconstruct PSF fitting into components
 *
 * Mike Blanton
 * 2/2006 */
 
#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

int nmf(float *data, float *ivar, int ndata, int nim, float *coeffs,
        float *templates, int nc);

int dfitpsf(float *atlas,
            float *atlas_ivar,
            int nx,
            int ny,
            int nim,
            float *psfc,
            float *psft,
            float *xpsf,
            float *ypsf,
            int nc,
            int np)
{
	int k,c;

  printf("%d %d %d %d\n", nx, ny, nc, nim); fflush(stdout);

	/* first do the full psf fit */
  nmf(atlas, atlas_ivar, nx*ny, nim, psfc, psft, nc);

	return(1);
} /* end dfitpsf */
