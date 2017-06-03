#include <stdio.h>
#include <stdlib.h>
/*

Converts ascii to ebcdic and back.

Uses assembly routines

#define STRING_SIZE 100000
#define ITERATIONS 100000

real    0m13.874s
user    0m13.864s
sys     0m0.002s

*/

#define STRING_SIZE 100000
#define ITERATIONS 100000

unsigned char ascii[STRING_SIZE];
unsigned char ebcdic[STRING_SIZE];


extern void ascii_to_ebcdic(unsigned char *ascii,unsigned char *ebcdic,long length);
extern void ebcdic_to_ascii(unsigned char *ascii,unsigned char *ebcdic,long length);

main()
{
	long i;

	for (i=0;i<STRING_SIZE;i++)
	{
		ascii[i]=random()%256;
	}

    ascii[0]='T';
    ascii[1]='e';
    ascii[2]='s';
    ascii[3]='t';
    ascii[4]=0;

    printf("before = %s\n",ascii);

	for (i=0;i<ITERATIONS;i++)
	{
		ascii_to_ebcdic(ascii,ebcdic,STRING_SIZE);
		ebcdic_to_ascii(ascii,ebcdic,STRING_SIZE);
	}

    printf("after = %s\n",ascii);
}

