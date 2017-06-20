#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*

Finds largest common substring between two strings.

Trying to unroll outer loop for performance due to pipelining.

#define STRING_SIZE 10000
#define ITERATIONS 100

*/

#define STRING_SIZE 10000
#define ITERATIONS 100

unsigned char str1[STRING_SIZE];
unsigned char str2[STRING_SIZE];

/* buffer for returned longest common string */

unsigned char common[STRING_SIZE];

extern long substring(unsigned char *str1,unsigned char *str2,unsigned char *common,long length);

main()
{
	long i;
	long common_size;

	for (i=0;i<STRING_SIZE;i++)
	{
		str1[i]=random()%128;
		str2[i]=random()%128;
	}

	str2[100]=str1[10]='T';
	str2[101]=str1[11]='e';
	str2[102]=str1[12]='s';
	str2[103]=str1[13]='t';

	for (i=0;i<ITERATIONS;i++)
	{
		common_size = substring(str1,str2,common,STRING_SIZE);
	}

    common[common_size]=0;

    printf("largest substring = %s\n",common);
}

