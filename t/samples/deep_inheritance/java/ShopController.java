class ShopController {

    public void main(){
        Human owner = new Human();
        owner.name = "Robson";

        VenderShop vender = new VenderShop();
        vender.sellDogTo(owner);
    }
}
