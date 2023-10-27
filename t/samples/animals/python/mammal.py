from abc import abstractmethod
from animal import Animal

class Mammal(Animal):
    @abstractmethod
    def close(self):
        pass
