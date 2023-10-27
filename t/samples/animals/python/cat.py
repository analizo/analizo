from mammal import Mammal

class Cat(Mammal):
    def __init__ (self, name):
        self.__name = name

    def name(self) -> str:
        return self.__name
