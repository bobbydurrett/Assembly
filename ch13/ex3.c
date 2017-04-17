#include <stdio.h>

/*

Chapter 13 Exercise 3

Big positive integer structure to compute 50!.

This is 64 bit C so a long is 64 bits which is a qword in assembly.

*/

struct bigposint
{
	long numqwords; /* number of qwords in array that are in use */
	long qwords[4]; /* 50! fits in 4 qwords so use array for 4 longs */
};

/* assembly routines */

extern void bigposint_to_string(struct bigposint *bigptr,char *buffer);
extern void set_bigposint(struct bigposint *bigptr,long value);
extern void add_bigposint(struct bigposint *targetptr,struct bigposint *sourceptr);

void
print_bigposint(char *prefix,struct bigposint *bigptr)
{
	char output[10000];
    bigposint_to_string(bigptr,output);
    printf("%s%s\n",prefix,output);
}

void
mult_bigposit(struct bigposint *bigptr,long small)
{
	struct bigposint curval;
	long i;
	set_bigposint(&curval,0);
	add_bigposint(&curval,bigptr); /* set curval to bigptr value */
	for (i=1;i < small;i++) /* add small-1 times */
		add_bigposint(bigptr,&curval);
}

main()
{
struct bigposint big;
char output[10000];
long i;

set_bigposint(&big,50); /* start at 50 for 50! */

/* loop through rest of numbers < 50 for 50! */

for (i=49;i>0;i--)
{
	mult_bigposit(&big,i);
}

print_bigposint("50! = ",&big);

}

