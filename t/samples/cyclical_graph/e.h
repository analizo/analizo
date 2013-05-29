#ifndef _E_H_
#define _E_H_

class E {
  private:
    char* _name;
  public:
    E(char*);
    virtual const char* name();
};

#endif
