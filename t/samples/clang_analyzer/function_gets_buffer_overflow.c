#include <stdlib.h>
#include <stdio.h>

#define DEST_SIZE 10
void CWE242_Use_of_Inherently_Dangerous_Function__basic_15_bad()
{
  switch(6)
  {
    case 6:
    {
    char dest[DEST_SIZE];
    char *result;
      result = gets(dest);
      if (result == NULL)
      {
        printf("Error Condition: alter control flow to indicate action taken");
        exit(1);
      }
      dest[DEST_SIZE-1] = '\0';
      printf(dest);
    }
    break;
    default:
      printf("Benign, fixed string");
      break;
  }
}

int main(int argc, char * argv[])
{
  CWE242_Use_of_Inherently_Dangerous_Function__basic_15_bad();
  return 0;
}

