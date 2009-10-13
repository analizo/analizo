public class Main {
  public static void main(String[] args) {
    Animal dog = new Dog("Odie");
    Mammal cat = new Cat("Garfield");
    System.out.println(dog.name());
    System.out.println(cat.name());
  }
}
