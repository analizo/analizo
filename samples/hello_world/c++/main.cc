#include "hello_world.h"

int main() {
  HelloWorld* hello1 = new HelloWorld();
  HelloWorld* hello2 = new HelloWorld();

  hello1->say();
  hello2->say();

  delete hello1;
  delete hello2;
  
  return 0;
}

