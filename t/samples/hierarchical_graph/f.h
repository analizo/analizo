#ifndef _F_H_
#define _F_H_

class F {
  private:
    char* _name;
  public:
    F(char*);
    virtual const char* name();
};

#endif
