#ifndef _C_H_
#define _C_H_

class C {
  private:
    char* _name;
  public:
    C(char*);
    virtual const char* name();
};

#endif
