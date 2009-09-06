#include <iostream>
#include "hello_world.h"

int HelloWorld::_id_seq = 0;

HelloWorld::HelloWorld() {
  this->_id = (HelloWorld::_id_seq++);
}

void HelloWorld::destroy() {
  std::cout << "Goobdye, world! My id is " << this->_id << std::endl;
}

void HelloWorld::say() {
  std::cout << "Hello, world! My id is " << this->_id << std::endl;
}

