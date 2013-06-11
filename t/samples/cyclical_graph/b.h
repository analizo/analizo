#ifndef _B_H_
#define _B_H_

class B {
  private:
    char* _name;
  public:
    B(char*);
    virtual const char* name();
};

#endif
