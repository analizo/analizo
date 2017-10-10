#include "f.h"

F::F(char* name) {
  this->_name = name;
}

const char* F::name() {
  return this->_name;
}
