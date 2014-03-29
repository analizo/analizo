#include <stdlib.h>
#include <string.h>

#define BAD_SOURCE_FIXED_STRING "Fixed String"
#define SEARCH_CHAR 'S'

static int badStatic = 0;

void badSink(char * data)
{
  if(badStatic)
  {
    for (; *data != '\0'; data++)
    {
      if (*data == SEARCH_CHAR)
      {
        break;
      }
    }
    free(data);
  }
}

int main(int argc, char * argv[])
{
  char * data;

  data = (char*) malloc(100*sizeof(char));
  strcpy(data, BAD_SOURCE_FIXED_STRING);

  badSink(data);
  return 0;
}

