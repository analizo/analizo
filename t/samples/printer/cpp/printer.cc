#include <iostream>
#include <string>

using namespace std;

class Printer1 {
  private:
    string message;
  public:
    Printer1(string);
};

Printer1::Printer1(string msg) {
  this->message = msg;
}

class Printer2 {
  private:
    string message;
  public:
    Printer2(string);
};

Printer2::Printer2(string message) {
  this->message = message;
}

int main() {
  Printer1 p1("one");
  Printer2 p2("two");
  return 0;
}
