import dog
import cat
from animal import Animal
from mammal import Mammal

def main(): 
    dog = dog.Dog("Odie");
    cat = cat.Cat("Garfield");
    print(dog.name())
    print(cat.name())

if __name__ == '__main__':
    main()

