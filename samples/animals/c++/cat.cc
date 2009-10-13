#include "cat.h"

Cat::Cat(char* name) {
  this->_name = name;
}

const char* Cat::name() {
  return this->_name;
}
