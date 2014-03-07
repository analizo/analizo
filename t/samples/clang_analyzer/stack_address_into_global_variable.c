#include <string.h>

char *pointer;

int getWord(void)
{
  char word[] = "World";
  pointer = word;
  return strlen(pointer);
}

int main(void)
{
  int x = getWord();
  return x;
}

