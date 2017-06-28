// abstract base class
#include <iostream>
using namespace std;

class CPolygon {
  protected:
    int width, height;

    virtual int perimeter(void) =0;
  public:
    void set_values (int a, int b)
      { width=a; height=b; }
    virtual int area (void) =0;
  };

class CTetragon: public CPolygon {
  protected:
    virtual int perimeter(void) =0;
  public:
    virtual int area (void) =0;
  };

class CSquare: public CTetragon {
  protected:
    int perimeter(void)
      { return (width*4); }
  public:
    int area (void)
      { return (width * width); }
  };

class CRetangle: public CTetragon {
  protected:
    int perimeter(void)
      { return (width*2 + height*2); }
  public:
    int area (void)
      { return (width * height); }
  };


class CTriangle: public CPolygon {
  protected:
    int perimeter(void)
      { return (width*3); }
  public:
    int area (void)
      { return (width * height / 2); }
  };

int main () {
  CRectangle rect;
  CTriangle trgl;
  CPolygon * ppoly1 = &rect;
  CPolygon * ppoly2 = &trgl;
  ppoly1->set_values (4,5);
  ppoly2->set_values (4,5);
  cout << ppoly1->area() << endl;
  cout << ppoly2->area() << endl;
  return 0;
}
