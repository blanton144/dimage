#include <string.h>
#include <stdio.h>
#include "fitsio.h"
#include "dimage.h"

#define MAXNPEAKS 100000

static float *x=NULL;
static float *y=NULL;
static float *flux=NULL;

int main(int argc, char *argv[])
{
    fitsfile *fptr;         /* FITS file pointer, defined in fitsio.h */
    char card[FLEN_CARD];   /* Standard string lengths defined in fitsio.h */
    int status = 0, single = 0, nkeys, ii;
    int naxis,naxis1,naxis2,bitpix;
		int maxnpeaks=MAXNPEAKS, npeaks;
    long naxisn[2];
    long fpixel[2]={1L,1L};
    int tfields=0, i;
    unsigned long int bscale=1L,bzero=0L,kk,jj;
    float *thedata=NULL;
		float sigma;

    if (argc != 2) {
      fprintf(stderr,"Usage: fits2xy fitsname.fits \n");
      fprintf(stderr,"\n");
      fprintf(stderr,"Read a FITS file, find objects, and write out \n");
      fprintf(stderr,"X, Y, FLUX to stdout. \n");
      fprintf(stderr,"\n");
      fprintf(stderr,"   fits2xy 'file.fits[0]'   - list primary array header \n");
      fprintf(stderr,"   fits2xy 'file.fits[2]'   - list header of 2nd extension \n");
      fprintf(stderr,"   fits2xy file.fits+2    - same as above \n");
      fprintf(stderr,"\n");
      return(0);
    }

    if (!fits_open_file(&fptr, argv[1], READONLY, &status))
    {
      // check status

      fits_get_img_dim(fptr,&naxis,&status);
      if(status) {
	fits_report_error(stderr, status);
	exit(-1);
      }
      if(naxis!=2) {
	fprintf(stderr,"Invalid header: NAXIS is not 2!\n");
      }
      fits_get_img_size(fptr,2,naxisn,&status);
      if(status) {
	fits_report_error(stderr, status);
	exit(-1);
      }

      //      fprintf(stderr,"Got naxis=%d,na1=%d,na2=%d,bitpix=%d\n",
      //	     naxis,naxisn[0],naxisn[1],bitpix);

      thedata=(float *)malloc(naxisn[0]*naxisn[1]*sizeof(float));
      if(thedata==NULL) {
	fprintf(stderr,"Failed allocating data array.\n");
	exit(-1);
      }

      fits_read_pix(fptr,TFLOAT,fpixel,naxisn[0]*naxisn[1],NULL,thedata,
		    NULL,&status);
      
      x=(float *) malloc(maxnpeaks*sizeof(float));
      y=(float *) malloc(maxnpeaks*sizeof(float));
      if(x==NULL || y==NULL) {
	fprintf(stderr,"Failed allocating output arrays.\n");
	exit(-1);
      }
      flux=(float *) malloc(maxnpeaks*sizeof(float));
      simplexy( thedata, naxisn[0], naxisn[1], 1., 8., 1., 3., 1000, 
		maxnpeaks, &sigma, x, y, flux, &npeaks);
      
      fprintf(stdout, "# X Y FLUX\n");
      for(i=0;i<npeaks;i++) 
	fprintf(stdout, "%e %e %e\n", x[i], y[i], flux[i]);

      free(thedata);
      free(x); free(y);
    } 
    else {
      fprintf(stderr, "Error reading file %s\n",argv[1]);
      fits_report_error(stderr, status);
    }


    if (status == END_OF_FILE)  status = 0; /* Reset after normal error */

    fits_close_file(fptr, &status);


    if (status) fits_report_error(stderr, status); /* print any error message */
    return(status);
}
