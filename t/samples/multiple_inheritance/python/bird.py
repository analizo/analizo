from animal import Animal
from flying import Flying

class Bird(Animal, Flying):
    def fly(self):
        print("i'm flying")
