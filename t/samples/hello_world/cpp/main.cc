#include "hello_world.h"

int main() {
  HelloWorld hello1;
  HelloWorld hello2;

  hello1.say();
  hello2.say();

  // even if we don't need to destroy these objects explicitly, we call
  // destroy() to make this similar to the C code
  hello1.destroy();
  hello2.destroy();
  
  return 0;
}

