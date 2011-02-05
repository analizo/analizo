#include <hello.h>
#include <iostream>

int main() {
  HelloWorld hello;

  if (hello.message() != "Hello, world") {
    std::cout << "Test failed" << std::endl;
    return 1;
  }

  return 0;
}
