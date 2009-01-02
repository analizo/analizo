#include <stdio.h>
#include "module2.h"
#include "module3.h"

int main() {
  int localvar = 0;
  void (*f)();

  say_hello();
  say_bye();

  printf("variable = %d\n", variable);
  variable = 20;

  printf("variable = %d\n", variable);
  printf("localvar = %d\n", localvar);

  f = callback;
  f();

  return 0;
}
