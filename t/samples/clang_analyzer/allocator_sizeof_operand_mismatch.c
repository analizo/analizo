#include <stdlib.h>
#include <stdio.h>

static int staticTrue = 1; /* true */

void CWE467_Use_of_sizeof_on_Pointer_Type__int_05_bad()
{
  if(staticTrue)
  {
    {
      int * badInt = NULL;
      badInt = (int *)malloc(sizeof(badInt));
      *badInt = 5;
      printf(*badInt);
      free(badInt);
    }
  }
}
int main(int argc, char * argv[])
{
  CWE467_Use_of_sizeof_on_Pointer_Type__int_05_bad();
  return 0;
}

