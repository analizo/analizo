#include "d.h"

D::D(char* name) {
  this->_name = name;
}

const char* D::name() {
  return this->_name;
}
