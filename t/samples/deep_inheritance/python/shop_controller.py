from human import Human
from vender_shop import VenderShop

class ShopController:

    def main():
        owner: Human = Human()
        owner.name = "Robson"

        vender: VenderShop = VenderShop()
        vender.sellDogTo(owner)
    

