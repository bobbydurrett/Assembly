#include <stdio.h>
#include <stdlib.h>
/*

This is chapter 18 exercise 1.

v3 tries to improve on v2 by using SSE instructions
like those in the chapter.

#define IMAGE_SIZE 1000
#define ITERATIONS 500

real    0m2.048s
user    0m2.044s
sys     0m0.002s

*/

#define IMAGE_SIZE 1000
#define ITERATIONS 500

unsigned char image[IMAGE_SIZE][IMAGE_SIZE];
unsigned char convoluted_image[IMAGE_SIZE][IMAGE_SIZE];
signed char convolution[3][3];

extern void apply_convolution(unsigned char image[][IMAGE_SIZE],unsigned char convoluted_image[][IMAGE_SIZE],signed char convolution[][3],long image_size);

main()
{
	long i,j;

	for (i=0;i<IMAGE_SIZE;i++)
	    for (j=0;j<IMAGE_SIZE;j++)
		image[i][j]=(i*j)%256;

	for (i=0;i<3;i++)
	    for (j=0;j<3;j++)
	        convolution[i][j]=i-1;

	for (i=0;i<ITERATIONS;i++)
		apply_convolution(image,convoluted_image,convolution,IMAGE_SIZE);

	printf("image\n");
	printf("%d %d %d %d\n",image[0][0],image[1][0],image[2][0],image[3][0]);
	printf("%d %d %d %d\n",image[0][1],image[1][1],image[2][1],image[3][1]);
	printf("%d %d %d %d\n",image[0][2],image[1][2],image[2][2],image[3][2]);
	printf("%d %d %d %d\n",image[0][3],image[1][3],image[2][3],image[3][3]);

	printf("convolution\n");
	printf("%d %d %d\n",convolution[0][0],convolution[1][0],convolution[2][0]);
	printf("%d %d %d\n",convolution[0][1],convolution[1][1],convolution[2][1]);
	printf("%d %d %d\n",convolution[0][2],convolution[1][2],convolution[2][2]);

    printf("convoluted_image\n");
	printf("%d %d %d %d\n",convoluted_image[0][0],convoluted_image[1][0],convoluted_image[2][0],convoluted_image[3][0]);
	printf("%d %d %d %d\n",convoluted_image[0][1],convoluted_image[1][1],convoluted_image[2][1],convoluted_image[3][1]);
	printf("%d %d %d %d\n",convoluted_image[0][2],convoluted_image[1][2],convoluted_image[2][2],convoluted_image[3][2]);
	printf("%d %d %d %d\n",convoluted_image[0][3],convoluted_image[1][3],convoluted_image[2][3],convoluted_image[3][3]);
}

