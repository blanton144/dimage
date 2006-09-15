
int dfluxes(float *image, float *templates, float *weights, int nx, int ny,
            float *xcen, float *ycen, int nchild, float *children, 
            float sigma);
int dweights(float *image, float *invvar, int nx, int ny, int ntemplates, 
             float *templates, int nonneg, float *weights);
void dcholsl(float *a, int n, float p[], float b[], float x[]);
void dcholdc(float *a, int n, float p[]);
int dfind(int *image, int nx, int ny, int *object);
int dsmooth(float *image, int nx, int ny, float sigma, float *smooth);
int dobjects(float *image, float *smooth, int nx, int ny, 
						 float dpsf, float plim, int *objects);
int dnonneg(float *xx, float *invcovar, float *bb, float offset,
            int nn, float tolerance, int maxiter, int *niter, float *chi2,
            int verbose);
int dpeaks(float *image, int nx, int ny, int *npeaks, int *xcen, 
           int *ycen, float sigma, float dlim, float saddle, int maxnpeaks,
           int smooth, int checkpeaks, float minpeak);
int dcentral(float *image, int nx, int ny, int npeaks, float *xcen, 
             float *ycen, int *central, float sigma, float dlim,    
             float saddle, int maxnpeaks);
int dmsmooth(float *image, int nx, int ny, int box, float *smooth);
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
						int dontsettemplates);
int dcen3x3(float *image, float *xcen, float *ycen);
int dsigma(float *image, int nx, int ny, int sp,float *sigma);
int dmedsmooth(float *image, float *invvar, int nx, int ny, int box,
							 float *smooth);
int dallpeaks(float *image, int nx, int ny, int *objects, float *xcen, 
							float *ycen, int *npeaks, float sigma, float dlim, float saddle, 
							int maxper, int maxnpeaks, float minpeak);
int simplexy(float *image, int nx, int ny, float dpsf, float plim,  
						 float dlim, float saddle, int maxper, int maxnpeaks,  
						 float *sigma, float *x, float *y, float *flux, int *npeaks);
int dtemplates(float *image, int nx, int ny, int *ntemplates, int *xcen, 
							 int *ycen, float *templates, float sigma, float parallel);
