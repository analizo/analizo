#include <stdio.h>
#include <stdlib.h>

#include "hello_world.h"

static int hello_world_id = 0;

hello_world* hello_world_new() {
  hello_world* obj = (hello_world*)(malloc(sizeof(hello_world)));
  obj->id = (hello_world_id++);
  return obj;
}

void hello_world_say(hello_world* hello_obj) {
  printf("Hello, world! My id is %d\n", hello_obj->id);
}

void hello_world_destroy(hello_world* hello_obj) {
  printf("Goodbye, world! My id is %d\n", hello_obj->id);
  free(hello_obj);
}

