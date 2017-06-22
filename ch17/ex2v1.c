#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*

Finds largest common substring between two strings.

#define STRING_SIZE 10000
#define ITERATIONS 100

real    0m27.229s
user    0m27.212s
sys     0m0.003s

*/

#define STRING_SIZE 10000
#define ITERATIONS 100

unsigned char str1[STRING_SIZE];
unsigned char str2[STRING_SIZE];

/* buffer for returned longest common string */

unsigned char common[STRING_SIZE];

long
substring(unsigned char *str1,unsigned char *str2,unsigned char *common,long length)
{
    long len_longest,start_longest,first1,first2,cur1,cur2;

    len_longest = 0;

    for (first1 = 0;first1 < length;first1++)
    {
    	 for (first2 = 0;first2 < length; first2++)
    	 {
    		 if (str1[first1] == str2[first2])
    		 {
    			 cur1 = first1 + 1;
    			 cur2 = first2 + 1;
    			 while ((cur1 < length) && (cur2 < length))
    			 {
    				 if (str1[cur1] != str2[cur2])
    				     break;
    				 cur1++;
    				 cur2++;
    			 }
    			 if ((cur1 - first1) > len_longest)
    			 {
    				 len_longest = cur1 - first1;
    				 start_longest = first1;
    			 }
    		 }
    	 }
    }

    strncpy(common,str1+start_longest, len_longest);
    return len_longest;
}


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

