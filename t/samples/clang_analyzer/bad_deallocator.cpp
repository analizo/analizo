#include <stdlib.h>

static char * badSource(char * data)
{
  data = NULL;
  data = (char *)realloc(data, 100*sizeof(char));
  return data;
}

void bad()
{
  char * data;
  data = NULL;
  data = badSource(data);
  delete data;
}

int main(int argc, char * argv[])
{
  bad();
  return 0;
}

