#include "e.h"
#include "f.h"
#include <iostream>

E::E(char* name) {
  this->_name = name;
}

const char* E::name() {
  F* f = new F("Letter F");
  std::cout << f->name() << std::endl;
  return this->_name;
}
