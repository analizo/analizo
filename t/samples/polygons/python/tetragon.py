from abc import abstractmethod
from polygon import Polygon

class Tetragon(Polygon):
    @abstractmethod
    def area(self):
        pass