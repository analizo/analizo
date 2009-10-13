#ifndef _CAT_H_
#define _CAT_H_

#include "mammal.h"

class Cat : public Mammal {
  private:
    char* _name;
  public:
    Cat(char*);
    virtual const char* name();
};

#endif
