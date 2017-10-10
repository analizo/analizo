using System;

class Program {
  static void Main() {
    Square square = new Square(2);
    Rect rect = new Rect(2,3);
    Triangle triangle = new Triangle(4,7);

    Console.WriteLine("Area: {0}, Perimeter: {1}", square.Area(), square.Perimeter());
    Console.WriteLine("Area: {0}, Perimeter: {1}", rect.Area(), rect.Perimeter());
    Console.WriteLine("Area: {0}, Perimeter: {1}", triangle.Area(), triangle.Perimeter());
  }
}
