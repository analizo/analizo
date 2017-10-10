using c;
using b;
using System;

public class Program {
  static void Main(string[] args) {
    B b = new B("Letter B");
    C c = new C("Letter C");

    Console.WriteLine(b.name());
    Console.WriteLine(c.name());
  }
}
