from four_legged_animal import FourLeggedAnimal

class Dog(FourLeggedAnimal):
    def describe():    
        result = super.describe();
        result += " In fact, it's a dog!";
        return result;
    
