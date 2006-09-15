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

static float *templates=NULL;
static float *coeffs=NULL;

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

  printf("%d %d %d %d\n", nx, ny, nc, nim); fflush(stdout);

  nmf(atlas, atlas_ivar, nx*ny, nim, psfc, psft, nc);

  FREEVEC(templates);
  FREEVEC(coeffs);
	return(1);
} /* end dfitpsf */
