#include <stdlib.h>
#include <stdio.h>

#define CHAR_ARRAY_SIZE 8

static const int STATIC_CONST_FIVE = 5;

void CWE194_Unexpected_Sign_Extension__fgets_malloc_06_bad()
{
  short data;
  data = 0;
  if(STATIC_CONST_FIVE==5)
  {
    {
      char inputBuffer[CHAR_ARRAY_SIZE] = "";
      if (fgets(inputBuffer, CHAR_ARRAY_SIZE, stdin) != NULL)
      {
        data = (short)atoi(inputBuffer);
      }
      else
      {
        printf("fgets() failed.");
      }
    }
  }
  if (data < 100)
  {
    char * dataBuffer = (char *)malloc(data);
    memset(dataBuffer, 'A', data-1);
    dataBuffer[data-1] = '\0';
    printf(dataBuffer);
    free(dataBuffer);
  }
}

int main(int argc, char * argv[])
{
  CWE194_Unexpected_Sign_Extension__fgets_malloc_06_bad();
  return 0;
}

