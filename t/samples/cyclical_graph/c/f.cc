#include "f.h"
#include "c.h"
#include <iostream>

F::F(char* name) {
  this->_name = name;
}

const char* F::name() {
  C* c = new C("Letter C");
  std::cout << c->name() << std::endl;
  return this->_name;
}
