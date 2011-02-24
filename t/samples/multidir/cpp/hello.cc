#include <iostream>
#include "hello.h"

int main() {
  HelloWorld hello;
  std::cout << hello.message() << std::endl;
  return 0;
}
