#ifndef _HELLO_WORLD_H_
#define _HELLO_WORLD_H_

class HelloWorld {
  private:
    int _id;
    static int _id_seq;
  public:
    HelloWorld();
    void say();
    void destroy();
};

#endif // _HELLO_WORLD_H_
