#include "animal.h"
#include "mammal.h"
#include "cat.h"
#include "dog.h"

#include <iostream>

int main() {
  Animal* dog = new Dog("Odie");
  Mammal* cat = new Cat("Garfield");

  std::cout << dog->name() << std::endl;
  std::cout << cat->name() << std::endl;

  return 0;
}
