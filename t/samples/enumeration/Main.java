public class Main {
  enum MyEnumeration {
    A, B, C, D
  }
  public static void main(String[] args) {
    MyEnumeration enumeration = MyEnumeration.A;
    if (enumeration.equals(MyEnumeration.A)) {
      System.out.println("Hello, World!");
    }
  }
}
