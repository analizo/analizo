#include "dog.h"

Dog::Dog(char* name) {
  this->_name = name;
}

const char* Dog::name() {
  return this->_name;
}
