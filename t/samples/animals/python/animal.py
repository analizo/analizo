from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def name(self) -> str:
        pass