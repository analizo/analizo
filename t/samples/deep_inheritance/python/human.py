from dog import Dog

class Human:
    def __init__(self) -> None:
        self.name = None
        self.pet: Dog = None

    def get_pet_name(self):
        return self.pet.name

