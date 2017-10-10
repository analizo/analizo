#include "b.h"
#include "c.h"
#include <iostream>

int main() {
  B* b = new B("Letter B");
  C* c = new C("Letter C");

  std::cout << b->name() << std::endl;
  std::cout << c->name() << std::endl;

  return 0;
}
