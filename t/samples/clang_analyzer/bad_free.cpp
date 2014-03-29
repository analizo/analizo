#include <wchar.h>

void bad()
{
    long * data;
    data = NULL; /* Initialize data */
    switch(6)
    {
    case 6:
    {
        long dataBuffer;
        dataBuffer = 5L;
        data = &dataBuffer;
    }
    break;
    default:
        break;
    }
    delete data;
}

int main(int argc, char * argv[])
{
  bad();
  return 0;
}

