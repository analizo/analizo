#include <stdlib.h>
#include <string.h>

#define BUFFERSIZE 256
int main(int argc, char** argv) {
  char *buf1, *buf2;
  buf1 = (char*) malloc(sizeof(char)*BUFFERSIZE);
  buf2 = (char*) malloc(sizeof(char)*BUFFERSIZE);
  strcpy(buf1, argv[1]);
  free(buf2);
}
