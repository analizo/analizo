#ifndef _HELLO_WORLD_H_
#define _HELLO_WORLD_H_

typedef struct _hello_world {
  int id;
} hello_world;

hello_world* hello_world_new();

void hello_world_say(hello_world*);

void hello_world_destroy(hello_world*);

#endif // _HELLO_WORLD_H_
