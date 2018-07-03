class VenderShop {

    public void sellDogTo(Human owner){
        Dog dog = new Dog();
        dog.name = "Toby";
        dog.owner = owner;

        owner.pet = dog;
    }
}
