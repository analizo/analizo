#include "c.h"
#include "e.h"
#include <iostream>

C::C(char* name) {
  this->_name = name;
}

const char* C::name() {
  E* e = new E("Letter E");
  std::cout << e->name() << std::endl;
  return this->_name;
}
