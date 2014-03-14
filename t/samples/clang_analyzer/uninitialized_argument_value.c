#include <wchar.h>

#define GLOBAL_CONST_FIVE 0

static void G2B1()
{
  char * data;
  char * dataBadBuffer = (char *)ALLOCA(50*sizeof(char));
  char * dataGoodBuffer = (char *)ALLOCA(100*sizeof(char));
  if(GLOBAL_CONST_FIVE!=5)
  {
    printf("Benign, fixed string");
  }
  else
  {
    data = dataGoodBuffer;
    data[0] = '\0'; /* null terminate */
  }
  {
    char source[100];
    memset(source, 'C', 100-1); /* fill with 'C's */
    source[100-1] = '\0'; /* null terminate */
    strncpy(data, source, 100-1);
    data[100-1] = '\0'; /* Ensure the destination buffer is null terminated */
    printf(data);
  }
}

int main(int argc, char * argv[])
{
  G2B1();
  return 0;
}

