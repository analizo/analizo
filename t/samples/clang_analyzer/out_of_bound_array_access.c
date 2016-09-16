#include <wchar.h>
#include <stdio.h>

static const int STATIC_CONST_TRUE = 1; /* true */

void CWE121_Stack_Based_Buffer_Overflow__CWE805_char_declare_ncat_04_bad()
{
  char * data;
  char dataBadBuffer[50];
  char dataGoodBuffer[100];
  if(STATIC_CONST_TRUE)
  {
    data = dataBadBuffer;
    data[0] = '\0'; /* null terminate */
  }
  {
    char source[100];
    memset(source, 'C', 100-1); /* fill with 'C's */
    source[100-1] = '\0'; /* null terminate */
    strncat(data, source, 100);
    printf(data);
  }
}

int main(int argc, char * argv[])
{
  CWE121_Stack_Based_Buffer_Overflow__CWE805_char_declare_ncat_04_bad();
  return 0;
}

