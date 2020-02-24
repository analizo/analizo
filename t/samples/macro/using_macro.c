// https://github.com/analizo/analizo/issues/154

#include <stdio.h>

SOME_EXTERNAL_MACRO(1);

int main(int argc, char **argv) {
  printf("this program has just this one main() method");
}
