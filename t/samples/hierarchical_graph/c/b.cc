#include "b.h"
#include "d.h"
#include <iostream>

B::B(char* name) {
  this->_name = name;
}

const char* B::name() {
  D* d = new D("Letter D");
  std::cout << d->name() << std::endl;
  return this->_name;
}
