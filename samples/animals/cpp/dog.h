#ifndef _DOG_H_
#define _DOG_H_

#include "mammal.h"

class Dog : public Mammal {
  private:
    char* _name;
  public:
    Dog(char*);
    virtual const char* name();
};

#endif
