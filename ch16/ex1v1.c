#include <stdio.h>
#include <math.h>

/*

Getting matrix with distance between a bunch of 3 dimensional points.
v1 is all c version with simple implementation.

Average runtime for 20000 points is 3.538 seconds.
Ten executions.

*/

#define NUM_POINTS 32

float x[NUM_POINTS];
float y[NUM_POINTS];
float z[NUM_POINTS];
float distance[NUM_POINTS][NUM_POINTS];

void
calc_distance(long num_points,float x[],float y[],float z[],float distance[][NUM_POINTS])
{
long i,j;
float xdiff,ydiff,zdiff;

for (i=0;i<num_points;i++)
    for (j=0;j<num_points;j++)
    {
		xdiff = x[j]-x[i];
		ydiff = y[j]-y[i];
		zdiff = z[j]-z[i];

		distance[i][j]=sqrtf(xdiff*xdiff+ydiff*ydiff+zdiff*zdiff);
	}
}

main()
{
	long i;
	long j;

/* simple fast initialization */

	for (i=0;i<NUM_POINTS;i++)
	{
		x[i]=i;
		y[i]=i;
		z[i]=i;
	}

	calc_distance(NUM_POINTS,x,y,z,distance);

	for (i=0;i<NUM_POINTS;i++)
	    for (j=0;j<NUM_POINTS;j++)
	        printf("distance[%ld][%ld]=%f\n",i,j,distance[i][j]);

}

