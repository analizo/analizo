#include <wchar.h>

void bad()
{
  int i,j;
  int * data;
  data = NULL;
  for(i = 0; i < 1; i++)
  {
    data = new int;
    delete data;
  }
  for(j = 0; j < 1; j++)
  {
    delete data;
  }
}

int main(int argc, char * argv[])
{
  bad();
  return 0;
}

