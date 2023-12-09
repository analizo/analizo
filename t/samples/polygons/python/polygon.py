from abc import Abc, abstractmethod
class Polygon(Abc):

    def __init__(self, width, height=None):
        self._width = width
        if height:
            self._height = height
    
    @abstractmethod
    def area(self):
        pass
