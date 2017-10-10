#ifndef _D_H_
#define _D_H_

class D {
  private:
    char* _name;
  public:
    D(char*);
    virtual const char* name();
};

#endif
