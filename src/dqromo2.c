#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "dimage.h"
#define EPS 1.0e-4
#define JMAX 14
#define JMAXP (JMAX+1)
#define K 5

float dqromo2(float (*func)(float), float a, float b,
							float (*choose)(float(*)(float), float, float, int))
{
	int j;
	float ss,dss,h[JMAXP+1],s[JMAXP+1];

	h[1]=1.0;
	for (j=1;j<=JMAX;j++) {
		s[j]=(*choose)(func,a,b,j);
		if (j >= K) {
			dpolint2(&h[j-K],&s[j-K],K,0.0,&ss,&dss);
			if (fabs(dss) < EPS*fabs(ss) || ss<EPS) return ss;
		}
		s[j+1]=s[j];
		h[j+1]=h[j]/9.0;
	}
	printf("%le %le\n",dss,ss);
	printf("Too many steps in routing qromo\n");
	exit(1);
	return 0.0;
}
#undef EPS
#undef JMAX
#undef JMAXP
#undef K
