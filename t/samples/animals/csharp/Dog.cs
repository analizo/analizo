public class Dog : Mammal {
  private string _name;
  public Dog(string name) {
    _name = name;
  }
  public override string name() {
    return _name;
  }
}
