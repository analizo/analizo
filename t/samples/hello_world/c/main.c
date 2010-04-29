#include "hello_world.h"

int main() {
  hello_world* hello1 = hello_world_new();
  hello_world_say(hello1);

  hello_world* hello2 = hello_world_new();
  hello_world_say(hello2);

  hello_world_destroy(hello1);
  hello_world_destroy(hello2);
  return 0;
}

