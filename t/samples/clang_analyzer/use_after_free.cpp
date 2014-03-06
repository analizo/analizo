#include <stdio.h>

int main()
{
  char * data;
  data = new char [10];
  data[1] = 'A';

  delete [] data;

  printf(data);
}

