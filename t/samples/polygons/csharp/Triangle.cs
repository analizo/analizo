using System;

class Triangle : Polygon {
  public Triangle(int w, int h) {
    this.width = w;
    this.heigth = h;
  }

  public override int Area() {
    return (width * heigth / 2);
  }

  public override int Perimeter() {
    return (width * 3);
  }
}
