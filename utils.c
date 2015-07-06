#include "utils.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

char *itoa(int i) {
  /* Room for INT_DIGITS digits, - and '\0' */
  static char buf[21];
  char *p = buf +  20;	/* points to terminating '\0' */
  if (i >= 0) {
    do {
      *--p = '0' + (i % 10);
      i /= 10;
    } while (i != 0);
    return p;
  }
  else {			/* i < 0 */
    do {
      *--p = '0' - (i % 10);
      i /= 10;
    } while (i != 0);
    *--p = '-';
  }
  return p;
}

char *strcat_copy(char *str1,char *str2) {
    int str1_len, str2_len;
    char *new_str;

    /* null check */

    str1_len = strlen(str1);
    str2_len = strlen(str2);

    new_str = malloc(str1_len + str2_len + 1);

    /* null check */

    memcpy(new_str, str1, str1_len);
    memcpy(new_str + str1_len, str2, str2_len + 1);

    return new_str;
}


	
