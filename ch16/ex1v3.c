#include <stdio.h>
#include <math.h>

/*

Getting matrix with distance between a bunch of 3 dimensional points.
v3 calls assembly version of calc_distance with difference from v2.

3.4856 seconds with 20000 points 10 execution average

*/

#define NUM_POINTS 20000

float x[NUM_POINTS];
float y[NUM_POINTS];
float z[NUM_POINTS];
float distance[NUM_POINTS][NUM_POINTS];

extern void calc_distance(long num_points,float x[],float y[],float z[],float distance[][NUM_POINTS]);

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

/*	for (i=0;i<NUM_POINTS;i++)
	    for (j=0;j<NUM_POINTS;j++)
	        printf("distance[%ld][%ld]=%f\n",i,j,distance[i][j]); */

}

